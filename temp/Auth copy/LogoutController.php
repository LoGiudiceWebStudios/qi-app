<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class LogoutController extends Controller
{
    /**
     * user logout
     */
    public function Logout()
    {
        // Check if the user is authenticated
        if (Auth::check()) {
            Auth::user()->tokens()->delete(); // Delete all tokens for the authenticated user
            Log::info('User logged out successfully.');
            // Return response
            return response()->json([
                'status' => true,
                'message' => 'User logged out successfully.',
                'code' => 200,
            ], 200);
        }

        // If the user is not authenticated
        Log::warning('Logout attempt failed: User not authenticated.', ['timestamp' => now()]);
        return $this->sendError('Unauthorized', ['error' => 'User is not authenticated.'], 401);
    }



}
