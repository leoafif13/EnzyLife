
import chromadb
from sentence_transformers import SentenceTransformer
import os
import time
from dotenv import load_dotenv
from google import genai


# 1. Memuat model embedding
MODEL_NAME = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
model = SentenceTransformer(MODEL_NAME)


# 2. Menghubungkan ke database ChromaDB
client = chromadb.PersistentClient(path="./chroma_db")

collection = client.get_or_create_collection(
    name="enzylife_knowledge"
)


# 3. Mencari konteks yang relevan
def retrieve_context(query: str, n_results: int = 3) -> list[str]:
    jumlah_dokumen = collection.count()

    if jumlah_dokumen == 0:
        return []

    query_embedding = model.encode([query]).tolist()

    results = collection.query(
        query_embeddings=query_embedding,
        n_results=min(n_results, jumlah_dokumen),
        include=["documents", "metadatas", "distances"]
    )

    documents = results["documents"][0] or []

    for i, document in enumerate(documents, start=1):
        print(f"\n--- Konteks {i} ---")
        print(document)

    return documents


# 4. Menghubungkan ke Gemini
load_dotenv(override=True)

api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    raise ValueError(
        "GEMINI_API_KEY belum ditemukan di file .env"
    )

gemini_client = genai.Client(api_key=api_key)


# 5. Menghasilkan jawaban berdasarkan konteks
def generate_answer(
    query: str,
    history: list[dict[str, str]] | None = None
) -> str:
    try:
        contexts = retrieve_context(query)

        if not contexts:
            return (
                "Maaf, informasi yang relevan belum ditemukan "
                "dalam basis pengetahuan EnzyLife."
            )

        context_text = "\n\n".join(contexts)

        history_lines = []

        if history:
            for message in history:
                role = message.get("role")
                content = message.get("content", "").strip()

                if role in ("user", "assistant") and content:
                    label = (
                        "Pengguna"
                        if role == "user"
                        else "Asisten EnzyLife"
                    )
                    history_lines.append(f"{label}: {content}")

        history_text = "\n".join(history_lines)

        prompt = f"""
Kamu adalah asisten edukasi Eco Enzyme pada aplikasi EnzyLife.

Jawablah pertanyaan terbaru pengguna dengan memanfaatkan
riwayat percakapan dan konteks referensi yang tersedia.

Aturan:
- Utamakan informasi faktual dari konteks referensi.
- Gunakan riwayat untuk memahami pertanyaan lanjutan.
- Riwayat percakapan bukan sumber fakta yang otomatis benar.
- Jangan mengarang fakta atau mengklaim sesuatu didukung
  jurnal jika tidak ada dalam konteks.
- Jika informasi yang dibutuhkan tidak tersedia, sampaikan
  dengan jujur.
- Gunakan bahasa Indonesia yang jelas dan mudah dipahami.
- Tetap fokus pada Eco Enzyme dan fitur EnzyLife.

Riwayat percakapan sebelumnya:
{history_text or "(Belum ada riwayat percakapan.)"}

Konteks referensi dari knowledge base:
{context_text}

Pertanyaan terbaru pengguna:
{query}
"""

        # Coba maksimal 3 kali jika Gemini mengalami HTTP 503
        for percobaan in range(3):
            try:
                response = gemini_client.models.generate_content(
                    model="gemini-3.5-flash",
                    contents=prompt
                )

                return (
                    response.text
                    or "Maaf, jawaban belum dapat dihasilkan."
                )

            except Exception as e:
                pesan_error = str(e)
                error_sementara = (
                    "503" in pesan_error
                    or "UNAVAILABLE" in pesan_error
                )

                if error_sementara and percobaan < 2:
                    waktu_tunggu = 2 ** (percobaan + 1)

                    print(
                        f"Gemini sedang sibuk. "
                        f"Percobaan {percobaan + 1} gagal. "
                        f"Mencoba lagi dalam {waktu_tunggu} detik..."
                    )

                    time.sleep(waktu_tunggu)
                    continue

                raise

    except Exception as e:
        print(f"Error saat menghasilkan jawaban RAG: {e}")

        return (
            "Maaf, layanan konsultasi EnzyLife sedang mengalami "
            "gangguan. Silakan coba lagi nanti."
        )


# 6. Menguji jawaban RAG
if __name__ == "__main__":
    pertanyaan = "Apa itu eco enzyme?"

    print("Pertanyaan:", pertanyaan)
    print("\nSedang menyusun jawaban...\n")

    jawaban = generate_answer(pertanyaan)

    print("Jawaban EnzyLife:")
    print(jawaban)
