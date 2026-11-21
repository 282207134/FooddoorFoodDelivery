# Run once from your Windows PowerShell to register Pixso with Codex.
& codex mcp add pixso-local --url 'http://localhost:3667/mcp'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& codex mcp get pixso-local
exit $LASTEXITCODE
