<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Infografik extends Model
{
    use HasFactory;
    protected $table = 'infografik';

    protected $primaryKey = 'id_infografik';

    protected $fillable = [
        'judul',
        'deskripsi',
        'gambar',
    ];
}
