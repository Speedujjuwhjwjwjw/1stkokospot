# 1st Koko Spot - Deployment Guide

## CodeMagic CI/CD Setup

### Prerequisites
- GitHub account with fork of this repository
- CodeMagic account (https://codemagic.io)
- Android signing key (keystore .jks file)
- iOS signing certificates (iOS Developer Program)
- Google Play Store account
- Apple App Store account
- Supabase credentials
- Paystack account

---

## 1. Initialize CodeMagic

### Step 1: Connect Repository
1. Go to **CodeMagic Dashboard** → **Repositories**
2. Click **Connect GitHub**
3. Authorize CodeMagic to access your repositories
4. Select `1stkokospot` repository

### Step 2: Import Configuration
1. CodeMagic will auto-detect `codemagic.yaml`
2. Review workflow configuration
3. Click **Create Workflow**

---

## 2. Environment Variables Setup

### Android Build Variables
In CodeMagic: **Settings** → **Environment variables**

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
PAYSTACK_CALLBACK_URL=https://yourdomain.com/checkout/complete
KEYSTORE_PASSWORD=your_keystore_password
KEY_ALIAS=androiddebugkey
KEY_PASSWORD=android
BUILD_NUMBER=1
```

### iOS Build Variables
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
PAYSTACK_CALLBACK_URL=https://yourdomain.com/checkout/complete
APP_BUNDLE_ID=com.kokospot.FoodOrderingApp
```

---

## 3. Android Signing Configuration

### Generate/Upload Signing Key
1. **Local**: Generate signing key
   ```bash
   cd food_ordering_app/android
   keytool -genkey -v -keystore release.keystore -keyalg RSA -keysize 2048 \
     -validity 10000 -alias release_key -keypass android -storepass android
   ```

2. **CodeMagic**: 
   - Go to **Settings** → **Integrations** → **Android Signing**
   - Upload `release.keystore`
   - Set reference as `keystore_reference`

3. **Add Google Play Credentials**:
   - Go to **Google Play Console** → **API Access**
   - Create Service Account
   - Download JSON key
   - In CodeMagic: Upload as `PLAY_STORE_CREDENTIALS`

---

## 4. iOS Signing Configuration

### Upload Certificates & Provisions
1. **CodeMagic** → **Settings** → **iOS Signing**
2. Upload Distribution Certificate (.p8 or .p12)
3. Upload Provisioning Profile
4. Set certificate password as `APP_CERTIFICATE_PASSWORD`

### Add App Store Credentials
1. **Apple Developer** → **App Store Connect**
2. Generate API Key (Key ID, Issuer ID, Private Key)
3. In CodeMagic: Add as `APP_STORE_CONNECT_CREDENTIALS`

---

## 5. Triggers & Testing

### Manual Workflow Trigger
1. Click **Start new build** in CodeMagic
2. Select workflow (android-build, ios-build, or web-build)
3. Monitor build logs in real-time

### Automatic Triggers
- Push to `main` branch → Build production release
- Push to `develop` branch → Build internal test release
- Pull requests → Run tests only

---

## 6. Build Outputs

### Android
- **APK**: `food_ordering_app/build/app/outputs/apk/debug/app-debug.apk`
- **AAB**: `food_ordering_app/build/app/outputs/bundle/release/app-release.aab`

### iOS
- **IPA**: `food_ordering_app/build/ios/ipa/KokoSpot.ipa`

### Web
- **Static Files**: `food_ordering_app/build/web/`
- Deployed to Firebase Hosting

---

## 7. Publishing to Stores

### Google Play Store
- Internal Track: Automatic (submit_as_draft: true)
- Staged Rollout: 5% → 25% → 100%
- Takes ~2-4 hours for review

### Apple App Store
- TestFlight Beta: Automatic to beta_groups
- Production Release: Manual via App Store Connect

### Web
- Auto-deployed to Firebase Hosting
- Public URL: `https://your-firebase-project.web.app`

---

## 8. Monitoring & Logs

### View Build Logs
- **CodeMagic Dashboard** → Click build
- Real-time logs stream during build
- Export logs after completion

### Common Issues
| Error | Fix |
|-------|-----|
| Java 25 incompatibility | CodeMagic uses Java 11 by default (configured in codemagic.yaml) |
| Supabase not initialized | Check `.env` variables are exported correctly |
| Signing failed | Verify keystore password and key alias match |
| Tests failing | Run `flutter test` locally before pushing |

---

## 9. Advanced: Custom Workflows

### Add Slack Notifications
Add to codemagic.yaml:
```yaml
notifications:
  slack:
    channel: "#builds"
    notify_on_branch: main
    template: success
```

### Add Discord Webhooks
```yaml
notifications:
  discord:
    webhook: $DISCORD_WEBHOOK_URL
```

### Conditional Publishing
```yaml
publishing:
  google_play:
    credentials: $PLAY_STORE_CREDENTIALS
    track: beta
    submit_as_draft: false
    conditionally_send: 'flutter_test_result == "success"'
```

---

## 10. Local Testing (Simulate CodeMagic Build)

```bash
cd food_ordering_app

# Set environment
export SUPABASE_URL="your_url"
export SUPABASE_ANON_KEY="your_key"
export PAYSTACK_CALLBACK_URL="your_url"

# Run tests
flutter test

# Build AAB
flutter build appbundle --release

# Build APK
flutter build apk --debug

# Build Web
flutter build web --release
```

---

## Troubleshooting

### "Supabase not initialized"
- Check `.env` file has correct values
- Verify SUPABASE_URL ends without trailing slash

### "Build fails with Java error"
- CodeMagic uses Java 11 (set in `environment` section)
- If issue persists, downgrade Gradle version

### "Certificates/Credentials not found"
- Verify environment variables are set in CodeMagic
- Check certificate format (.p8 vs .p12)

### "Tests fail locally but pass in CI"
- Clear cache: `flutter clean && flutter pub get`
- Ensure `.env` file is not in git

---

## Security Best Practices

1. ✅ **Never commit .env file** (added to .gitignore)
2. ✅ **Store secrets in CodeMagic** env vars, not in code
3. ✅ **Rotate API keys** quarterly
4. ✅ **Use separate keys** for staging and production
5. ✅ **Enable 2FA** on all store/developer accounts
6. ✅ **Review build logs** for exposed credentials

---

## See Also
- [Flutter Build Documentation](https://flutter.dev/docs/deployment)
- [CodeMagic Documentation](https://docs.codemagic.io)
- [Supabase Setup](../food_ordering_app/SUPABASE_SETUP.md)
- [Paystack Integration](../food_ordering_app/PAYSTACK_INTEGRATION.md)
