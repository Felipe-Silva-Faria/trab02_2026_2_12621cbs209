# =============================================================================
# registrar_ativos_exemplo.ps1 - cadastra 4 ativos exemplo (4 vulnerabilidades cada)
# Projeto trab02_2026_2_12621cbs209 - CRUD de Ativos de TI
#
# Uso (com a API rodando):
#   .\registrar_ativos_exemplo.ps1                                   # API local 127.0.0.1:8000
#   .\registrar_ativos_exemplo.ps1 -Url http://localhost:2209        # Docker
#   .\registrar_ativos_exemplo.ps1 -Limpar                           # apaga os exemplos antes
# A chave vem de -Chave, de $env:CRUD_API_KEY ou de ~\.crud_chave_local.txt
#
# Regra da API: nomes de vulnerabilidade aceitam so letras, numeros, espaco, - . '
# (sem parenteses nem barras).
# =============================================================================
param(
    [string]$Url = "http://127.0.0.1:8000",
    [string]$Chave = $env:CRUD_API_KEY,
    [switch]$Limpar
)
$ErrorActionPreference = "Stop"

if (-not $Chave) {
    $arq = Join-Path $env:USERPROFILE ".crud_chave_local.txt"
    if (Test-Path $arq) { $Chave = (Get-Content $arq -Raw).Trim() }
}
if (-not $Chave) { throw "Informe a chave: -Chave <valor> ou `$env:CRUD_API_KEY" }
$H = @{ "X-API-Key" = $Chave }

# Invoke-WebRequest + decodificacao UTF-8 manual: o Windows PowerShell 5 le
# respostas sem charset como ISO-8859-1 (os acentos aparecem trocados na tela).
# Devolve a lista sempre como array (@()), para o pipeline enumerar os itens.
function Enviar($Metodo, $Rota, $Corpo) {
    $p = @{ Uri = "$Url$Rota"; Method = $Metodo; Headers = $H; UseBasicParsing = $true }
    if ($null -ne $Corpo) {
        $json = $Corpo | ConvertTo-Json -Depth 6
        $p.Body = [Text.Encoding]::UTF8.GetBytes($json)
        $p.ContentType = "application/json; charset=utf-8"
    }
    $r = Invoke-WebRequest @p
    $texto = [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray())
    if ([string]::IsNullOrWhiteSpace($texto)) { return @() }
    return @($texto | ConvertFrom-Json | ForEach-Object { $_ })
}

function Erro($e) {
    $msg = $e.ErrorDetails.Message
    if (-not $msg) { $msg = $e.Exception.Message }
    return $msg
}

# ---------------------------------------------------------------- 1. saude
$saude = Enviar GET "/health" $null
Write-Host "API $($saude.status) - versao $($saude.versao) em $Url" -ForegroundColor Green

# ---------------------------------------------------------------- 2. dados
$ativos = @(
    @{ nome = "srv-web-portal"; tipo = "Servidor"; local = "DMZ - Bloco A"
       vulnerabilidades = @(
         @{ nome = "Apache HTTP Server desatualizado - RCE"; vetor_cvss = "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H"
            responsavel = "Equipe Web"; tratamento = "Atualizar o Apache para a versao corrigida" }
         @{ nome = "TLS 1.0 e 1.1 habilitados"; vetor_cvss = "CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:N/A:N"
            responsavel = "Equipe Web"; tratamento = "Aceitar somente TLS 1.2 e 1.3" }
         @{ nome = "XSS refletido no formulario de busca"; vetor_cvss = "CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:L/I:L/A:N"
            responsavel = "Desenvolvimento"; tratamento = "Escapar saidas e aplicar Content-Security-Policy" }
         @{ nome = "Listagem de diretorios ativa"; vetor_cvss = "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N"
            responsavel = "Equipe Web"; tratamento = "Desativar Options Indexes" }
       ) }
    @{ nome = "db-financeiro"; tipo = "Banco de Dados"; local = "Datacenter UFU"
       vulnerabilidades = @(
         @{ nome = "Senha padrao na conta do DBA"; vetor_cvss = "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H"
            responsavel = "DBA"; tratamento = "Trocar a senha e ativar politica de senhas" }
         @{ nome = "Porta 5432 exposta para toda a rede"; vetor_cvss = "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:L"
            responsavel = "Redes"; tratamento = "Restringir acesso por firewall ao servidor de aplicacao" }
         @{ nome = "Backups sem criptografia"; vetor_cvss = "CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N"
            responsavel = "DBA"; tratamento = "Criptografar backups (AES-256)" }
         @{ nome = "Usuario da aplicacao com privilegios excessivos"; vetor_cvss = "CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N"
            responsavel = "DBA"; tratamento = "Aplicar menor privilegio (somente SELECT/INSERT/UPDATE)" }
       ) }
    @{ nome = "rt-borda-01"; tipo = "Roteador"; local = "Rack de borda"
       vulnerabilidades = @(
         @{ nome = "Telnet habilitado na gerencia"; vetor_cvss = "CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N"
            responsavel = "Redes"; tratamento = "Desativar Telnet e usar SSH" }
         @{ nome = "Firmware desatualizado - negacao de servico"; vetor_cvss = "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H"
            responsavel = "Redes"; tratamento = "Atualizar firmware em janela de manutencao" }
         @{ nome = "SNMP com community public"; vetor_cvss = "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N"
            responsavel = "Redes"; tratamento = "Migrar para SNMPv3 com autenticacao" }
         @{ nome = "CSRF na interface web de administracao"; vetor_cvss = "CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H"
            responsavel = "Redes"; tratamento = "Restringir a interface a rede de gerencia" }
       ) }
    @{ nome = "ws-financeiro-07"; tipo = "Estacao de Trabalho"; local = "Setor Financeiro"
       vulnerabilidades = @(
         @{ nome = "Sistema operacional sem patch - elevacao de privilegio"; vetor_cvss = "CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H"
            responsavel = "Suporte"; tratamento = "Aplicar atualizacoes mensais" }
         @{ nome = "Macros do Office habilitadas"; vetor_cvss = "CVSS:3.1/AV:L/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H"
            responsavel = "Suporte"; tratamento = "Bloquear macros de arquivos da internet por GPO" }
         @{ nome = "Antivirus desativado pelo usuario"; cvss = 4.0
            responsavel = "Suporte"; tratamento = "Reativar e impedir desativacao por politica" }
         @{ nome = "Usuario comum no grupo de administradores locais"; vetor_cvss = "CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:L/I:L/A:N"
            responsavel = "Suporte"; tratamento = "Remover do grupo Administradores" }
       ) }
)

# ---------------------------------------------------------------- 3. limpeza opcional
if ($Limpar) {
    foreach ($a in $ativos) {
        $existentes = Enviar GET "/ativos?busca=$([uri]::EscapeDataString($a.nome))&limite=1000" $null
        foreach ($x in @($existentes | Where-Object { $_.nome -eq $a.nome })) {
            Enviar DELETE "/ativos/$($x.id)" $null | Out-Null
            Write-Host "removido id=$($x.id) $($x.nome)" -ForegroundColor DarkYellow
        }
    }
}

# ---------------------------------------------------------------- 4. cadastro
$criados = @()
foreach ($a in $ativos) {
    try {
        $r = Enviar POST "/ativos" $a
    } catch {
        $msg = Erro $_
        Write-Host "[$($a.nome)] recusado: $msg" -ForegroundColor Red
        if ($msg -match 'tipo' -and $msg -notmatch 'vulnerabilidade') {
            Write-Host "  -> tipo '$($a.tipo)' nao aceito; repetindo com tipo 'Servidor'" -ForegroundColor Yellow
            $a.tipo = "Servidor"
            $r = Enviar POST "/ativos" $a
        } else { continue }
    }
    $r = $r[0]
    $criados += $r
    Write-Host ("[{0}] id={1} tipo={2} vulns={3} maior_cvss={4}" -f $r.nome, $r.id, $r.tipo, @($r.vulnerabilidades).Count, $r.maior_cvss) -ForegroundColor Cyan
}

# ---------------------------------------------------------------- 5. resumo
Write-Host "`nResumo dos ativos exemplo" -ForegroundColor Green
$criados | Select-Object id, nome, tipo, maior_cvss, risco_proprio, risco | Format-Table -AutoSize

Write-Host "Vulnerabilidades e notas CVSS calculadas pela API" -ForegroundColor Green
foreach ($r in $criados) {
    $r.vulnerabilidades | Select-Object @{n="ativo";e={$r.nome}}, nome, cvss, severidade | Format-Table -AutoSize
}

Write-Host "Relatorio de risco (top 10)" -ForegroundColor Green
Enviar GET "/relatorios/risco?limite=10" $null | Select-Object id, nome, risco_proprio, risco | Format-Table -AutoSize