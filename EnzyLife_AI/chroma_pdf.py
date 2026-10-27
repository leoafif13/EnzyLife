
from pathlib import Path

import chromadb
import pymupdf
from sentence_transformers import SentenceTransformer


# 1. Pengaturan
KNOWLEDGE_BASE_DIR = Path("knowledge_base")
CHUNK_SIZE = 700
CHUNK_OVERLAP = 150

MODEL_NAME = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"


# 2. Memuat model embedding
model = SentenceTransformer(MODEL_NAME)


# 3. Membuat database ChromaDB lokal
client = chromadb.PersistentClient(path="./chroma_db")

collection = client.get_or_create_collection(
    name="enzylife_knowledge"
)


# 4. Membaca teks dari PDF
def read_pdf(pdf_path: Path) -> str:
    text_parts = []

    with pymupdf.open(pdf_path) as pdf:
        for page in pdf:
            text = page.get_text("text").strip()

            if text:
                text_parts.append(text)

    return "\n\n".join(text_parts)


# 5. Membagi teks menjadi chunk
def split_text(text: str) -> list[str]:
    chunks = []
    start = 0

    while start < len(text):
        end = start + CHUNK_SIZE
        chunk = text[start:end].strip()

        if chunk:
            chunks.append(chunk)

        if end >= len(text):
            break

        start = end - CHUNK_OVERLAP

    return chunks

# 6. Memproses semua PDF
def ingest_pdfs():
    pdf_files = sorted(KNOWLEDGE_BASE_DIR.glob("*.pdf"))

    if not pdf_files:
        print("Tidak ada PDF di folder knowledge_base.")
        return

    total_chunks = 0

    for pdf_path in pdf_files:
        print(f"\nMemproses: {pdf_path.name}")

        text = read_pdf(pdf_path)

        if not text:
            print("Tidak ada teks yang berhasil diekstrak.")
            continue

        chunks = split_text(text)

        if not chunks:
            print("Tidak ada chunk yang dihasilkan.")
            continue

        # Hapus chunk lama dari PDF yang sedang diproses
        collection.delete(
            where={"source": pdf_path.name}
        )

        # Buat ID untuk chunk terbaru
        ids = [
            f"{pdf_path.stem}_chunk_{i}"
            for i in range(len(chunks))
        ]

        # Membuat embedding untuk setiap chunk
        embeddings = model.encode(
            chunks,
            show_progress_bar=True
        ).tolist()

        # Simpan chunk terbaru ke ChromaDB
        collection.upsert(
            ids=ids,
            documents=chunks,
            embeddings=embeddings,
            metadatas=[
                {
                    "source": pdf_path.name,
                    "chunk_index": i
                }
                for i in range(len(chunks))
            ]
        )

        total_chunks += len(chunks)

        print("Jumlah karakter:", len(text))
        print("Jumlah chunk baru:", len(chunks))
        print("Chunk lama dari PDF ini sudah diganti.")

    print("\n=== INGESTION SELESAI ===")
    print("Jumlah chunk diproses:", total_chunks)
    print("Total dokumen dalam collection:", collection.count())


# 7. Mencari informasi berdasarkan pertanyaan
def search_knowledge(query: str, n_results: int = 3):
    if collection.count() == 0:
        print("Database masih kosong.")
        return

    query_embedding = model.encode([query]).tolist()

    results = collection.query(
        query_embeddings=query_embedding,
        n_results=min(n_results, collection.count()),
        include=["documents", "metadatas", "distances"]
    )

    print("\nPertanyaan:", query)
    print("\nHasil pencarian:")

    for i, document in enumerate(results["documents"][0]):
        metadata = results["metadatas"][0][i]
        distance = results["distances"][0][i]

        print(f"\n--- Hasil {i + 1} ---")

        if metadata:
            print("Sumber:", metadata.get("source", "Tidak diketahui"))
            print("Chunk:", metadata.get("chunk_index", "Tidak diketahui"))
        else:
            print("Metadata: tidak tersedia")

        print("Jarak:", round(distance, 4))
        print("Isi:", document[:500])

# 8. Menjalankan program
if __name__ == "__main__":
    print("Total dokumen dalam collection:", collection.count())

    search_knowledge(
        "Apa manfaat Eco Enzyme untuk pertumbuhan tanaman?",
        n_results=3
    )
