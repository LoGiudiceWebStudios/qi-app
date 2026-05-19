<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Mail\OTPVerificationMail;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;

class OtpVerificationController extends Controller
{
    public function verifyOTP(Request $request)
    {
        // Validate OTP
        $validation = Validator::make($request->all(), [
            'email' => 'required|email',
            'otp'   => 'required|numeric',
        ]);

        // If validation fails, return error message
        if ($validation->fails()) {
            return $this->sendError('OTP Validation Error', $validation->errors()->first(), 422);
        }

        // Find the user by email
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return $this->sendError('User not found', ['error' => 'User with this email does not exist.'], 404);
        }

        // Check if OTP exists and is valid
        if ($user->otp !== $request->otp) {
            return $this->sendError('Invalid OTP', ['error' => 'The OTP is incorrect. Please try again.'], 400);
        }

        // Check if OTP is expired
        if ($user->otp_expires_at < now()) {
            return $this->sendError('OTP Expired', ['error' => 'The OTP has expired. Please request a new OTP.'], 400);
        }

        // Mark the user as verified
        $user->email_verified_at = now();
        $user->otp = null; // Clear the OTP
        $user->otp_expires_at = null;
        $user->save();

        $token = $user->createToken('RestApi')->plainTextToken;

        $success = [
            'id'    => $user->id,
            'name'  => $user->name,
            'email' => $user->email,
        ];

        // Respond with success
        return $this->sendResponse($success, 'Email verified successfully.', 200, $token);
    }

    public function resendOTP(Request $request)
    {
        // Validate email
        $validation = Validator::make($request->all(), [
            'email' => 'required|email',
        ]);

        // If validation fails, return error message
        if ($validation->fails()) {
            return $this->sendError('Resend OTP Validation Error', $validation->errors()->first(), 422);
        }

        // Find the user by email
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return $this->sendError('User not found', ['error' => 'User with this email does not exist.'], 404);
        }

        // Generate a new OTP
        $otp = rand(1000, 9999);
        $expiresAt = Carbon::now()->addMinutes(1);  // OTP expiration time 1 minutes

        // Save the OTP and expiration time to the database
        $user->otp = $otp;
        $user->otp_expires_at = $expiresAt;
        $user->save();

        // Send OTP email
        Mail::to($user->email)->send(new OTPVerificationMail($otp));

        // Return a response indicating OTP has been resent
        return $this->sendResponse([], 'A new OTP has been sent to your email address.', 200);
    }
}
