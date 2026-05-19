<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class LoginController extends Controller
{
     /**
     * user login
     */
    public function Login(Request $request)
    {
        // Validation
        $validation = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // If validation fails, return error message
        if ($validation->fails()) {
            return $this->sendError('Login Validation Error', $validation->errors()->toArray(), 422);
        }

        // Attempt to authenticate
        if (Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
            $user = Auth::user();

            // Check if email is verified
            if (!$user->hasVerifiedEmail()) {
                return $this->sendError('Email Not Verified', ['error' => 'Please verify your email address.'], 403);
            }

            // Generate token
            $token = $user->createToken('RestApi')->plainTextToken;

            $success = [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ];

            return $this->sendResponse($success, 'User logged in successfully.', 200, $token);
        } else {
            return $this->sendError('Unauthorized', ['error' => 'Invalid email or password.'], 401);
        }
    }
}
