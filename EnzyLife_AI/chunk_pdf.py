
from pathlib import Path
import pymupdf

KNOWLEDGE_BASE_DIR = Path("knowledge_base")
CHUNK_SIZE = 1000
CHUNK_OVERLAP = 200


def read_pdf(pdf_path: Path) -> str:
    text_parts = []

    with pymupdf.open(pdf_path) as pdf:
        for page in pdf:
            text = page.get_text("text").strip()

            if text:
                text_parts.append(text)

    return "\n\n".join(text_parts)


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


def main():
    pdf_files = list(KNOWLEDGE_BASE_DIR.glob("*.pdf"))

    if not pdf_files:
        print("Tidak ada PDF di folder knowledge_base.")
        return

    for pdf_path in pdf_files:
        text = read_pdf(pdf_path)
        chunks = split_text(text)

        print(f"\nFile: {pdf_path.name}")
        print(f"Jumlah karakter: {len(text)}")
        print(f"Jumlah chunk: {len(chunks)}")

        if chunks:
            print("\nContoh chunk pertama:")
            print(chunks[0])


if __name__ == "__main__":
    main()
