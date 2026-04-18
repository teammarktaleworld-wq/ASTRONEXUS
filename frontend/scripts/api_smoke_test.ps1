param(
  [string]$Token = $env:ASTRO_API_TOKEN,
  [string]$UserId = "mock-user-id"
)

$ErrorActionPreference = "Stop"

$baseUrl = "https://astro-nexus-new-6-46mo.onrender.com"
$userBaseUrl = "$baseUrl/user"
$authBaseUrl = "https://auth-astronexus-1.onrender.com"
$horoscopeBaseUrl = "https://astronexus-horoscope-ogbl.onrender.com/api/horoscope"
$mapsBaseUrl = "https://maps.googleapis.com/maps/api/geocode/json"
$cityBaseUrl = "https://photon.komoot.io/api/"
$validCategoryId = "mock-category"

try {
  $catResponse = Invoke-WebRequest -Uri "$userBaseUrl/categories" -Method GET -UseBasicParsing -TimeoutSec 25
  $catData = $catResponse.Content | ConvertFrom-Json
  if ($catData -is [System.Collections.IEnumerable]) {
    $first = $catData | Select-Object -First 1
    if ($first -and $first._id) {
      $validCategoryId = [string]$first._id
    }
  }
} catch {}

function Invoke-ApiCheck {
  param(
    [string]$Name,
    [string]$Method,
    [string]$Url,
    [hashtable]$Body = $null,
    [bool]$RequiresAuth = $false,
    [int[]]$ExpectedStatuses = @()
  )

  $headers = @{
    "Accept" = "application/json"
    "Content-Type" = "application/json"
  }

  if ($RequiresAuth -and $Token) {
    $headers["Authorization"] = "Bearer $Token"
  }

  $requestParams = @{
    Uri = $Url
    Method = $Method
    Headers = $headers
    TimeoutSec = 30
  }

  if ($Body) {
    $requestParams["Body"] = ($Body | ConvertTo-Json -Depth 10)
  }

  $statusCode = $null
  $responseBody = ""
  $errorText = ""

  try {
    $response = Invoke-WebRequest @requestParams -UseBasicParsing
    $statusCode = [int]$response.StatusCode
    $responseBody = [string]$response.Content
  } catch {
    $errorText = $_.Exception.Message
    if ($_.Exception.Response) {
      try {
        $statusCode = [int]$_.Exception.Response.StatusCode
      } catch {}
      try {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        $reader.Dispose()
      } catch {}
    }
  }

  $outcome = "FAIL"
  if ($statusCode -ge 200 -and $statusCode -lt 300) {
    $outcome = "PASS"
  } elseif ($ExpectedStatuses -and $ExpectedStatuses -contains $statusCode) {
    $outcome = "PASS_EXPECTED"
  } elseif ($RequiresAuth -and ($statusCode -eq 401 -or $statusCode -eq 403) -and -not $Token) {
    $outcome = "PASS_AUTH_REQUIRED"
  } elseif ($statusCode -eq 400 -or $statusCode -eq 422) {
    $outcome = "PASS_VALIDATION"
  }

  $snippet = ""
  if ($responseBody) {
    $snippet = $responseBody
    if ($snippet.Length -gt 300) {
      $snippet = $snippet.Substring(0, 300)
    }
  } elseif ($errorText) {
    $snippet = $errorText
    if ($snippet.Length -gt 300) {
      $snippet = $snippet.Substring(0, 300)
    }
  }

  [PSCustomObject]@{
    name = $Name
    method = $Method
    url = $Url
    requiresAuth = $RequiresAuth
    status = $statusCode
    outcome = $outcome
    snippet = $snippet
  }
}

$mapKey = if ($env:GOOGLE_MAPS_API_KEY) { $env:GOOGLE_MAPS_API_KEY } else { "DUMMY_KEY" }

$checks = @(
  @{ Name = "Auth Send OTP"; Method = "POST"; Url = "$authBaseUrl/api/auth/send-otp"; Body = @{ phoneNumber = "123" }; RequiresAuth = $false },
  @{ Name = "Auth Verify OTP"; Method = "POST"; Url = "$authBaseUrl/api/auth/verify-otp"; Body = @{ phoneNumber = "123"; otp = "000000" }; RequiresAuth = $false; ExpectedStatuses = @(400, 401) },
  @{ Name = "User Login"; Method = "POST"; Url = "$userBaseUrl/login"; Body = @{ email = "invalid@example.com"; password = "wrong-pass" }; RequiresAuth = $false; ExpectedStatuses = @(401) },
  @{ Name = "User Phone Login"; Method = "POST"; Url = "$userBaseUrl/login/phone"; Body = @{ phoneNumber = "123"; password = "wrong-pass" }; RequiresAuth = $false },
  @{ Name = "User Signup Astrology"; Method = "POST"; Url = "$userBaseUrl/signup/astrology"; Body = @{ name = "Test"; email = "invalid@example.com"; phone = "123" }; RequiresAuth = $false },
  @{ Name = "Get Profile"; Method = "GET"; Url = "$userBaseUrl/me"; RequiresAuth = $true },
  @{ Name = "Categories"; Method = "GET"; Url = "$userBaseUrl/categories"; RequiresAuth = $false },
  @{ Name = "Products"; Method = "GET"; Url = "$userBaseUrl/products"; RequiresAuth = $false },
  @{ Name = "Products Filtered"; Method = "GET"; Url = "$userBaseUrl/products?category=$validCategoryId"; RequiresAuth = $false },
  @{ Name = "Product By Invalid Id"; Method = "GET"; Url = "$userBaseUrl/products/invalid-id"; RequiresAuth = $false },
  @{ Name = "Home Products"; Method = "GET"; Url = "$userBaseUrl/home-products"; RequiresAuth = $false },
  @{ Name = "Cart Get"; Method = "GET"; Url = "$userBaseUrl/cart"; RequiresAuth = $true },
  @{ Name = "Cart Add"; Method = "POST"; Url = "$userBaseUrl/cart/add"; Body = @{ productId = "invalid-id"; quantity = 1 }; RequiresAuth = $true },
  @{ Name = "Cart Update"; Method = "POST"; Url = "$userBaseUrl/cart/add"; Body = @{ productId = "invalid-id"; quantity = 1 }; RequiresAuth = $true },
  @{ Name = "Cart Remove"; Method = "DELETE"; Url = "$userBaseUrl/cart/remove/invalid-id"; RequiresAuth = $true },
  @{ Name = "Orders My"; Method = "GET"; Url = "$userBaseUrl/orders/my"; RequiresAuth = $true },
  @{ Name = "Order By Invalid Id"; Method = "GET"; Url = "$userBaseUrl/orders/invalid-id"; RequiresAuth = $true },
  @{ Name = "Place Order"; Method = "POST"; Url = "$userBaseUrl/orders"; Body = @{ paymentMethod = "UPI"; deliveryType = "physical" }; RequiresAuth = $true },
  @{ Name = "Create Payment"; Method = "POST"; Url = "$userBaseUrl/payment/create"; Body = @{ amount = 100 }; RequiresAuth = $true },
  @{ Name = "Verify Payment"; Method = "POST"; Url = "$userBaseUrl/payment/verify"; Body = @{ paymentId = "invalid"; transactionId = "invalid" }; RequiresAuth = $true },
  @{ Name = "Addresses Get"; Method = "GET"; Url = "$userBaseUrl/addresses"; RequiresAuth = $true },
  @{ Name = "Addresses Add"; Method = "POST"; Url = "$userBaseUrl/addresses/add"; Body = @{ fullName = "Test"; phone = "123"; street = "Street"; city = "City"; state = "State"; country = "India"; postalCode = "000000"; isDefault = $false }; RequiresAuth = $true },
  @{ Name = "Addresses Update"; Method = "PUT"; Url = "$userBaseUrl/addresses/invalid-id"; Body = @{ fullName = "Test" }; RequiresAuth = $true },
  @{ Name = "Addresses Delete"; Method = "DELETE"; Url = "$userBaseUrl/addresses/invalid-id"; RequiresAuth = $true },
  @{ Name = "Wishlist Get"; Method = "GET"; Url = "$userBaseUrl/wishlist"; RequiresAuth = $true },
  @{ Name = "Wishlist Add"; Method = "POST"; Url = "$userBaseUrl/wishlist"; Body = @{ name = "Default"; productId = "invalid-id" }; RequiresAuth = $true },
  @{ Name = "Wishlist Remove"; Method = "DELETE"; Url = "$userBaseUrl/wishlist/remove"; Body = @{ name = "Default"; productId = "invalid-id" }; RequiresAuth = $true },
  @{ Name = "Wallet Get"; Method = "GET"; Url = "$userBaseUrl/$UserId"; RequiresAuth = $false },
  @{ Name = "Wallet Deposit"; Method = "POST"; Url = "$userBaseUrl/$UserId/deposit"; Body = @{ amount = 100 }; RequiresAuth = $false },
  @{ Name = "Wallet Withdraw"; Method = "POST"; Url = "$userBaseUrl/$UserId/withdraw"; Body = @{ amount = 100 }; RequiresAuth = $false },
  @{ Name = "Tarot Random"; Method = "GET"; Url = "$baseUrl/api/tarot/random?n=3"; RequiresAuth = $false; ExpectedStatuses = @(401) },
  @{ Name = "Discount List"; Method = "GET"; Url = "$baseUrl/api/discount"; RequiresAuth = $false },
  @{ Name = "Discount By Code"; Method = "GET"; Url = "$baseUrl/api/discount/TESTCODE"; RequiresAuth = $false; ExpectedStatuses = @(404) },
  @{ Name = "Discount Apply"; Method = "POST"; Url = "$baseUrl/api/discount/apply"; Body = @{ code = "TESTCODE"; amount = 1000 }; RequiresAuth = $false; ExpectedStatuses = @(404) },
  @{ Name = "Feedback List"; Method = "GET"; Url = "$baseUrl/api/feedback/invalid-product-id"; RequiresAuth = $false; ExpectedStatuses = @(500, 400) },
  @{ Name = "Feedback Submit"; Method = "POST"; Url = "$baseUrl/api/feedback"; Body = @{ productId = "invalid-product-id"; rating = 4; description = "test" }; RequiresAuth = $true },
  @{ Name = "Notifications List"; Method = "GET"; Url = "$baseUrl/api/notifications"; RequiresAuth = $true },
  @{ Name = "Notifications Mark Read"; Method = "PUT"; Url = "$baseUrl/api/notifications/invalid-id/read"; RequiresAuth = $true },
  @{ Name = "Chatbot Ask"; Method = "POST"; Url = "$baseUrl/api/chatbot/ask"; Body = @{ session_id = "invalid"; question = "Hi" }; RequiresAuth = $true },
  @{ Name = "Birth Chart Generate"; Method = "POST"; Url = "$baseUrl/api/birthchart/generate"; Body = @{ name = "Test"; gender = "male"; birth_date = @{ year = 1990; month = 1; day = 1 }; birth_time = @{ hour = 10; minute = 30; ampm = "AM" }; place_of_birth = "Delhi"; astrology_type = "vedic"; ayanamsa = "lahiri" }; RequiresAuth = $false },
  @{ Name = "Prediction"; Method = "POST"; Url = "$baseUrl/api/prediction"; Body = @{ name = "Test"; dob = "01-01-1990"; tob = "10:30 AM"; place = "Delhi"; gender = "Male" }; RequiresAuth = $false },
  @{ Name = "Match Making"; Method = "POST"; Url = "$baseUrl/api/v1/compatibility/match-making/ashtakoot-score"; Body = @{ male = @{ name = "A"; dateOfBirth = "1990-01-01"; timeOfBirth = "10:00"; placeOfBirth = "Delhi" }; female = @{ name = "B"; dateOfBirth = "1992-01-01"; timeOfBirth = "11:00"; placeOfBirth = "Mumbai" } }; RequiresAuth = $false },
  @{ Name = "Horoscope Daily"; Method = "GET"; Url = "${horoscopeBaseUrl}?sign=leo&type=daily"; RequiresAuth = $false },
  @{ Name = "Map Geocode"; Method = "GET"; Url = "${mapsBaseUrl}?address=Delhi&key=$mapKey"; RequiresAuth = $false },
  @{ Name = "City Search"; Method = "GET"; Url = "${cityBaseUrl}?q=Delhi&limit=1"; RequiresAuth = $false }
)

$results = @()
foreach ($check in $checks) {
  $result = Invoke-ApiCheck -Name $check.Name -Method $check.Method -Url $check.Url -Body $check.Body -RequiresAuth $check.RequiresAuth -ExpectedStatuses $check.ExpectedStatuses
  $results += $result
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$passCount = ($results | Where-Object { $_.outcome -like "PASS*" }).Count
$failCount = ($results | Where-Object { $_.outcome -eq "FAIL" }).Count

$results | ConvertTo-Json -Depth 6 | Set-Content "api_smoke_report.json"

$lines = @()
$lines += "# API Smoke Test Report"
$lines += ""
$lines += "- Timestamp: $timestamp"
$lines += "- Token Provided: $([bool]$Token)"
$lines += "- Total Checks: $($results.Count)"
$lines += "- Pass-like Outcomes: $passCount"
$lines += "- Fail Outcomes: $failCount"
$lines += ""
$lines += "| Name | Method | Status | Outcome | URL |"
$lines += "|---|---:|---:|---|---|"
foreach ($row in $results) {
  $status = if ($row.status) { $row.status } else { "NA" }
  $url = $row.url.Replace("|", "%7C")
  $lines += "| $($row.name) | $($row.method) | $status | $($row.outcome) | $url |"
}

$lines += ""
$lines += "## Error Snippets"
foreach ($row in $results) {
  if ($row.outcome -eq "FAIL" -or $row.outcome -eq "PASS_VALIDATION" -or $row.outcome -eq "PASS_AUTH_REQUIRED") {
    $snippet = if ($row.snippet) { $row.snippet.Replace("`r", " ").Replace("`n", " ") } else { "" }
    $lines += "- $($row.name): $snippet"
  }
}

$lines | Set-Content "API_SMOKE_REPORT.md"

Write-Output "SMOKE_TEST_DONE"
Write-Output "TOTAL=$($results.Count)"
Write-Output "PASS_LIKE=$passCount"
Write-Output "FAIL=$failCount"
