<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Infografik extends Model
{
    protected $table = 'infografik';

    protected $primaryKey = 'id_infografik';

    protected $fillable = [
        'judul',
        'deskripsi',
        'gambar',
    ];
}
