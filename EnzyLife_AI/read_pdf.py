from pathlib import Path
import pymupdf

# Folder tempat PDF knowledge base disimpan
KNOWLEDGE_BASE_DIR = Path("knowledge_base")


def read_pdf(pdf_path: Path) -> str:
    """Membaca dan menggabungkan teks dari seluruh halaman PDF."""
    text_parts = []

    with pymupdf.open(pdf_path) as pdf:
        for page_number, page in enumerate(pdf, start=1):
            text = page.get_text("text").strip()

            if text:
                text_parts.append(text)

    return "\n\n".join(text_parts)


def main():
    pdf_files = list(KNOWLEDGE_BASE_DIR.glob("*.pdf"))

    if not pdf_files:
        print("Tidak ada file PDF di folder knowledge_base.")
        return

    for pdf_path in pdf_files:
        print(f"\nMemproses: {pdf_path.name}")

        try:
            text = read_pdf(pdf_path)

            if not text:
                print("Tidak ada teks yang berhasil diekstrak.")
                continue

            print(f"Jumlah karakter: {len(text)}")
            print("\nCuplikan teks:")
            print(text[:1500])

        except Exception as error:
            print(f"Gagal membaca PDF: {error}")


if __name__ == "__main__":
    main()