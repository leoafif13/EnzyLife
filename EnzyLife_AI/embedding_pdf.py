
from sentence_transformers import SentenceTransformer

# 1. Memuat model embedding
MODEL_NAME = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"

model = SentenceTransformer(MODEL_NAME)


# 2. Menyiapkan contoh teks
teks = [
    "Eco enzyme merupakan produk hasil fermentasi bahan organik.",
    "Eco enzyme berpotensi digunakan sebagai pupuk organik cair.",
    "Python adalah bahasa pemrograman."
]


# 3. Mengubah teks menjadi embedding
embeddings = model.encode(teks)


# 4. Menampilkan hasil
print("Jumlah teks:", len(teks))
print("Bentuk embedding:", embeddings.shape)

print("\nEmbedding teks pertama:")
print(embeddings[0])

print("\nPanjang vektor:", len(embeddings[0]))
