
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity

MODEL_NAME = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"

model = SentenceTransformer(MODEL_NAME)

teks = [
    "Eco enzyme dapat digunakan sebagai pupuk organik cair.",
    "Eco enzyme berpotensi membantu pertumbuhan tanaman.",
    "Python adalah bahasa pemrograman."
]

embeddings = model.encode(teks)

# Menghitung kemiripan setiap pasangan teks
similarity_matrix = cosine_similarity(embeddings)

print("Matriks kemiripan:\n")
print(similarity_matrix)

print("\nPerbandingan teks pertama:")
print(teks[0])

for i in range(1, len(teks)):
    score = similarity_matrix[0][i]
    print(f"\nDibandingkan dengan: {teks[i]}")
    print(f"Skor kemiripan: {score:.4f}")
