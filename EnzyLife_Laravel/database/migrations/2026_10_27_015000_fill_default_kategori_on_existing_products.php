<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $samples = [
            1 => json_encode(['Kompor & Area Dapur', 'Pel Lantai', 'Cuci Piring']),
            2 => json_encode(['Pel Lantai', 'Kamar Mandi', 'Saluran Air', 'Penghilang Bau']),
            3 => json_encode(['Air Purifier', 'Penghilang Bau', 'Cuci Pakaian']),
            4 => json_encode(['Kompor & Area Dapur', 'Pel Lantai', 'Pupuk Organik', 'Pestisida Sayuran']),
        ];

        $products = DB::table('products')->get();
        foreach ($products as $p) {
            $cat = $p->kategori;
            // Jika kosong, null, atau string kosong
            if (empty($cat) || $cat === 'null' || $cat === '[]') {
                $val = $samples[$p->id] ?? json_encode(['Kompor & Area Dapur', 'Pel Lantai']);
                DB::table('products')->where('id', $p->id)->update(['kategori' => $val]);
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // No reverse needed
    }
};
