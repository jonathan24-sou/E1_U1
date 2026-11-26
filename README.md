# Ejercicio 3 — Flutter

Solución práctica de Git avanzado, persistencia local, consumo de API y almacenamiento seguro.

## Ejecutar

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

La app consulta el tipo de cambio MXN y presenta USD/EUR. La base local Floor se compone de `Category` y `Note`; el DAO filtra por categoría y ordena por fecha descendente.

## Ejercicio 3.1 — Git avanzado

El historial tiene un commit inicial en `main` y dos commits de trabajo en `feature/login`. Después se simuló un cambio independiente en `main`, se produjo un conflicto de README y se integró `main` en la rama de trabajo con `git merge`, resolviendo el README para conservar ambas aportaciones.

Para publicar el repositorio y abrir un PR cuando exista un remoto GitHub:

```powershell
git remote add origin https://github.com/<usuario>/<repositorio>.git
git push -u origin main
git push -u origin feature/login
gh pr create --base main --head feature/login --title "Ejercicios 3.1–3.4" --body "Agrega notas locales, consulta de divisas y almacenamiento seguro."
```

## Ejercicio 3.2 — Base de datos local (Floor)

- `Category`: `id`, `name`, `color`.
- `Note`: `id`, `title`, `content`, `date` (`DateTime`, guardado como epoch en milisegundos), `categoryId`.
- `categoryId` referencia `Category.id` y elimina sus notas en cascada.
- `NoteDao.findByCategory(categoryId)` devuelve solo esa categoría ordenada por `date DESC`.

El código y la prueba SQLite en memoria están en `lib/data/` y `test/data/note_dao_test.dart`.

## Ejercicio 3.3 — Consumo de API (Dio)

`ExchangeRateService` consulta `https://api.exchangerate-api.com/v4/latest/MXN` con límites de tiempo de conexión/envío/recepción, valida y parsea la respuesta JSON a `ExchangeRates`, y distingue timeout, red, HTTP 404, HTTP 5xx y otros códigos HTTP. `ExchangeRatePage` muestra USD/EUR y ofrece reintento.

## Ejercicio 3.4 — Seguridad de tokens

En Flutter, `TokenStorage` usa `flutter_secure_storage`; guarda, lee y elimina el JWT con el almacén seguro del sistema. Ejemplo:

```dart
final tokens = TokenStorage();
await tokens.save(jwt);
final String? savedJwt = await tokens.read();
```

### Android — EncryptedSharedPreferences (Kotlin)

Dependencia para la API de AndroidX Security Crypto:

```kotlin
implementation("androidx.security:security-crypto:1.1.0-alpha06")
```

Guardar y leer el JWT:

```kotlin
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()
val securePrefs = EncryptedSharedPreferences.create(
    context,
    "secure_prefs",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)
securePrefs.edit().putString("jwt_token", jwt).apply()
val savedJwt = securePrefs.getString("jwt_token", null)
```

`EncryptedSharedPreferences` está obsoleto en las versiones nuevas de AndroidX Security Crypto; se incluye porque el ejercicio lo solicita y es útil al mantener apps existentes.

### iOS — Keychain Services (Swift)

```swift
import Foundation
import Security

enum KeychainToken {
    private static let service = Bundle.main.bundleIdentifier ?? "com.example.notes"
    private static let account = "jwt_token"

    static func save(_ token: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: Data(token.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    static func read() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8) else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
        return token
    }
}
```
