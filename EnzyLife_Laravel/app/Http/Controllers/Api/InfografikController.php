<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Infografik;

class InfografikController extends Controller
{
    public function index()
    {
        return response()->json(
            Infografik::latest()->get()
        );
    }

    public function show($id)
    {
        $infografik = Infografik::findOrFail($id);

        return response()->json($infografik);
    }
}