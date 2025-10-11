# Безопасность
- Ключи валидаторов: offline generation, парольные файлы вне VCS, CI запрет доступа.
- RPC hardening: привязка 127.0.0.1/ACL/Nginx mTLS; CORS disabled по умолчанию.
- Secrets: .env вне репо, Git-secrets, pre-commit.
- Supply chain: pin image digest, SBOM, npm/yarn audit для contracts.
