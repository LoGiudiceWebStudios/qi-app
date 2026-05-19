<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Mail\OTPVerificationMail;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

class RegistrationController extends Controller {
    public function Registration(Request $request)
    {
        // Validation
        $validation = Validator::make($request->all(), [
            'name'     => 'required',
            'email'    => 'required|email|unique:users',
            'password' => 'required|confirmed',
        ]);

        // If validation fails, return error message
        if ($validation->fails()) {
            return $this->sendError('Registration Validation Error', $validation->errors()->first(), 422);
        }

        // Create user
        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Generate OTP
        $otp = rand(1000, 9999); // Generate a random 6-digit OTP
        $otpExpiration = now()->addMinutes(1); // OTP will expire in 10 minutes

        // Save OTP and expiration time to the user record
        $user->otp = $otp;
        $user->otp_expires_at = $otpExpiration;
        $user->save();

        // Send OTP email
        Mail::to($user->email)->send(new OTPVerificationMail($otp));

        // Return success response
        return $this->sendResponse( [], 'Registration successful. Please verify your email using the OTP sent to your email address.');
    }
}
