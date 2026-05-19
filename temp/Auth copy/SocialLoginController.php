<?php

namespace App\Http\Controllers\Api\Auth;

use App\Helpers\Helper;
use App\Http\Controllers\Controller;
use App\Models\User;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;

class SocialLoginController extends Controller {
    public function RedirectToProvider($provider): RedirectResponse {
        return Socialite::driver($provider)->redirect();
    }

    public function HandleProviderCallback($provider): void {
        $socialUser = Socialite::driver($provider)->stateless()->user();
        // dd($socialUser);
    }

    public function SocialLogin(Request $request): JsonResponse {
        $request->validate([
            'token'    => 'required',
            'provider' => 'required|in:google,facebook,apple',
        ]);

        try {
            $provider   = $request->provider;
            $socialUser = Socialite::driver($provider)->stateless()->userFromToken($request->token);

            if ($socialUser) {
                $user      = User::where('email', $socialUser->email)->first();
                $isNewUser = false;

                if (!$user) {
                    $password = Str::random(16);
                    $user     = User::create([
                        'name'              => $socialUser->getName(),
                        'email'             => $socialUser->getEmail(),
                        'password'          => bcrypt($password),
                        'email_verified_at' => now(),
                    ]);
                    $isNewUser = true;
                }

                Auth::login($user);
                $token = $user->createToken('auth_token')->plainTextToken;

                $responseData = [
                    'id'    => $user->id,
                    'name'  => $user->name,
                    'email' => $user->email,
                ];

                return response()->json([
                    'status'     => true,
                    'message'    => $isNewUser ? 'User registered successfully' : 'User logged in successfully',
                    'code'       => 200,
                    'token_type' => 'bearer',
                    'token'      => $token,
                    'data'       => $responseData,
                ]);
            } else {
                return Helper::jsonResponse(false, 'Unauthorized', 401);
            }
        } catch (Exception $e) {
            return Helper::jsonResponse(false, 'Something went wrong', 500, ['error' => $e->getMessage()]);
        }
    }
}
