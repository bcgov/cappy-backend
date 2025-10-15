<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Models\Application;
use App\Http\Resources\ApplicationResource;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


Route::get('/applications', function () {
    return ApplicationResource::collection(Application::all());
});

Route::get('/applications/{id}', function (Application $application) {
    return new ApplicationResource($application);
});