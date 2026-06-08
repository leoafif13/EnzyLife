<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $type === 'verification' ? 'Verifikasi Akun EnzyLife' : 'Reset Password EnzyLife' }}</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            background-color: #f4f7f6;
            margin: 0;
            padding: 0;
            -webkit-font-smoothing: antialiased;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            border: 1px solid #e2e8f0;
        }
        .header {
            background: linear-gradient(135deg, #1B5E20, #2E7D32, #4CAF50);
            padding: 40px 20px;
            text-align: center;
            color: #ffffff;
        }
        .header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 800;
            letter-spacing: -0.5px;
        }
        .content {
            padding: 40px 30px;
            color: #2d3748;
            line-height: 1.6;
        }
        .content p {
            font-size: 16px;
            margin-top: 0;
            margin-bottom: 20px;
        }
        .otp-container {
            text-align: center;
            margin: 30px 0;
        }
        .otp-code {
            display: inline-block;
            font-size: 36px;
            font-weight: 800;
            color: #2E7D32;
            background-color: #e8f5e9;
            padding: 12px 36px;
            border-radius: 12px;
            letter-spacing: 6px;
            border: 2px dashed #4CAF50;
        }
        .footer {
            background-color: #f8fafc;
            padding: 24px 30px;
            text-align: center;
            font-size: 13px;
            color: #718096;
            border-top: 1px solid #edf2f7;
        }
        .footer p {
            margin: 0;
        }
        .warning-text {
            font-size: 13px;
            color: #e53e3e;
            background-color: #fff5f5;
            padding: 12px;
            border-radius: 8px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>EnzyLife</h1>
        </div>
        <div class="content">
            @if ($type === 'verification')
                <p>Halo,</p>
                <p>Terima kasih telah mendaftar di <strong>EnzyLife</strong>! Silakan gunakan kode OTP di bawah ini untuk memverifikasi alamat email Anda agar dapat menikmati seluruh layanan kami:</p>
                <div class="otp-container">
                    <span class="otp-code">{{ $otp }}</span>
                </div>
                <p>Kode OTP ini berlaku selama <strong>15 menit</strong>. Jangan bagikan kode ini kepada siapapun.</p>
            @else
                <p>Halo,</p>
                <p>Kami menerima permintaan untuk merestart/mengatur ulang password akun <strong>EnzyLife</strong> Anda. Gunakan kode OTP di bawah ini untuk melanjutkan proses reset password:</p>
                <div class="otp-container">
                    <span class="otp-code">{{ $otp }}</span>
                </div>
                <p>Kode OTP ini berlaku selama <strong>15 menit</strong>. Jika Anda tidak merasa melakukan permintaan ini, abaikan email ini.</p>
                <div class="warning-text">
                    <strong>Penting:</strong> Demi keamanan akun Anda, jangan berikan kode OTP ini kepada orang lain.
                </div>
            @endif
        </div>
        <div class="footer">
            <p>&copy; {{ date('Y') }} EnzyLife. Eco Enzyme untuk Hidup Lebih Baik.</p>
        </div>
    </div>
</body>
</html>
