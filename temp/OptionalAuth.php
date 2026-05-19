<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class OptionalAuth
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        // Tenta di autenticare l'utente, ma non obbligare
        Auth::shouldUse('sanctum'); // Specifica il guard di Sanctum
        if ($request->bearerToken()) {
            Auth::authenticate(); // Tenta di autenticare l'utente
        }

        return $next($request);
    }
}