<?php

namespace App\Http\Controllers\Api\Auth;

use Carbon\Carbon;
use App\Models\User;
use App\Mail\OTPMail;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Notification;
use App\Notifications\PasswordResetNotification;

class ForgotPasswordController extends Controller
{
    // Send reset code
    public function sendResetCode(Request $request)
    {
        // Validation
        $validation = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email',
        ]);
        // If validation fails, return error message
        if ($validation->fails()) {
            return $this->sendError('Forgot Password Validation Error', $validation->errors()->toArray(), 422); // Change the HTTP code if needed
        }

        try {
            // Generate a 4-digit random verification code
            $code = rand(1000, 9999);

            //save code and expire time in database
            $user = User::where('email', $request->email)->first();

            $user->reset_code            = $code;
            $user->reset_code_expires_at = Carbon::now()->addMinutes(5); // 5 minutes expiration
            $user->save();

            // Send email with code
            Notification::send($user, new PasswordResetNotification($code));
            // Log the successful response
            Log::info('Reset code sent to user ID: ' . $user->id);

            // Return response
            return response()->json([
                'status'  => true,
                'message' => 'Reset code sent to your email.',
                'code'    => 200,
            ], 200);
        } catch (\Throwable $e) {
            //throw $e;
            Log::error('Reset code sent error: ' . $e->getMessage());
            // Return a user-friendly error message
            return $this->sendError('Reset Code Sending Error', ['error' => 'An error occurred while sending the reset code. Please try again.'], 500);
        }
    }

    // Verify code
    public function verifyResetCode(Request $request)
    {
        // Validation
        $validation = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email',
            'code'  => 'required|digits:4|integer',
        ]);
        // If validation fails, return error message
        if ($validation->fails()) {
            Log::warning('Reset code validation failed');
            return $this->sendError('verify Reset Code Validation Error', $validation->errors()->toArray(), 422); // Change the HTTP code if needed
        }

        try {
            $user = User::where('email', $request->email)->first();

            if (!$user || $user->reset_code !== $request->code) {
                Log::error('Invalid reset code.');
                // Return response
                return response()->json([
                    'status'  => true,
                    'message' => 'Invalid reset code.',
                    'code'    => 400,
                ], 400);
            }

            // Check if the code is expired
            if (Carbon::now()->greaterThan($user->reset_code_expires_at)) {
                Log::error('Reset code has expired.');
                return response()->json([
                    'status'  => false,
                    'message' => 'Reset code has expired.',
                    'code'    => 400,
                ], 400);
            }

            // Code is valid
            Log::info('Reset code is valid');
            return response()->json([
                'status'  => true,
                'message' => 'Reset code is valid.',
                'code'    => 200,
            ], 200);
        } catch (\Throwable $e) {
            //throw $e;
            Log::error('Reset code sent error: ' . $e->getMessage());
            // Return a user-friendly error message
            return $this->sendError('verify Reset Code Error', ['error' => 'An error occurred while sending the verify Reset Code. Please try again.'], 500);
        }
    }

    // Reset password
    public function resetPassword(Request $request)
    {
        // Validation
        $validation = Validator::make($request->all(), [
            'email'    => 'required|email|exists:users,email',
            'code'     => 'required|digits:4|integer',
            'password' => 'required|confirmed|min:6',
        ]);
        // If validation fails, return error message
        if ($validation->fails()) {
            Log::warning('reset Password Validation Error');
            return $this->sendError('reset Password Validation Error', $validation->errors()->toArray(), 422); // Change the HTTP code if needed
        }

        try {
            $user = User::where('email', $request->email)->first();

            if (!$user || $user->reset_code !== $request->code) {
                Log::error('Invalid reset code.');
                // Return response
                return response()->json([
                    'status'  => true,
                    'message' => 'Invalid reset code.',
                    'code'    => 400,
                ], 400);
            }

            if (Carbon::now()->greaterThan($user->reset_code_expires_at)) {
                Log::error('Reset code has expired.');
                return response()->json([
                    'status'  => false,
                    'message' => 'Reset code has expired.',
                    'code'    => 400,
                ], 400);
            }

            // Reset password
            $user->password              = Hash::make($request->password);
            $user->reset_code            = null; // Clear the reset code
            $user->reset_code_expires_at = null; // Clear the expiration time
            $user->save();

            Log::info('Password reset successfully for user');

            // Return response
            return response()->json([
                'status'  => true,
                'message' => 'Password reset successfully.',
                'code'    => 200,
            ], 200);
        } catch (\Throwable $e) {
            //throw $e;
            Log::error('Reset code sent error: ' . $e->getMessage());
            // Return a user-friendly error message
            return $this->sendError('reset Password Error', ['error' => 'An error occurred while sending the reset Password. Please try again.'], 500);
        }
    }
}
