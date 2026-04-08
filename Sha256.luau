--- Author: COMT

--[[

  Sha256

]]

--!native
--!optimize 2
--!strict


-- -- Helpers

local bit32_band = bit32.band
local bit32_bnot = bit32.bnot
local bit32_bor = bit32.bor
local bit32_bxor = bit32.bxor
local bit32_rrotate = bit32.rrotate

local string_byte = string.byte
local string_format = string.format

-- SHA-256 constants
local K = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
}


-- -- End

return function sha256(bytes: {number}): (number, number, number, number, number, number, number, number)
  local length = #bytes
  local bitLength = length * 8

  -- append 0x80
  length += 1
  bytes[length] = 0x80

  -- pad with zeros until length ≡ 56 mod 64
  while (length % 64) ~= 56 do
    length += 1
    bytes[length] = 0
  end

  -- append 64-bit length (big-endian)
  bytes[length + 1] = bit32_band(bitLength // 56, 0xFF)
  bytes[length + 2] = bit32_band(bitLength // 48, 0xFF)
  bytes[length + 3] = bit32_band(bitLength // 40, 0xFF)
  bytes[length + 4] = bit32_band(bitLength // 32, 0xFF)
  bytes[length + 5] = bit32_band(bitLength // 24, 0xFF)
  bytes[length + 6] = bit32_band(bitLength // 16, 0xFF)
  bytes[length + 7] = bit32_band(bitLength // 8, 0xFF)
  bytes[length + 8] = bit32_band(bitLength, 0xFF)
  
  local h1, h2, h3, h4, h5, h6, h7, h8 = 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19  
  local w = {}

  for index = 0, length + 7, 64 do
    local chunk = {}
    for jndex = 1, 64 do
        chunk[jndex] = bytes[index + jndex]
    end

    for index = 0, 15 do
      local jndex = index * 4 + 1
      w[index] = bit32_bor(
        chunk[jndex] * 0x1000000,
        chunk[jndex + 1] * 0x10000,
        chunk[jndex + 2] * 0x100,
        chunk[jndex + 3]
      )
    end

    for t = 16, 63 do
      local s0 = bit32_bxor(bit32_rrotate(w[t - 15], 7), bit32_rrotate(w[t - 15], 18), w[t - 15] // 8)
      local s1 = bit32_bxor(bit32_rrotate(w[t - 2], 17), bit32_rrotate(w[t - 2], 19), w[t - 2] // 1024)
      w[t] = bit32_band((w[t - 16] + s0 + w[t - 7] + s1), 0xFFFFFFFF)
    end

    local a, b, c, d, e, f, g, h = h1, h2, h3, h4, h5, h6, h7, h8

    for t = 0, 63 do
        local S1 = bit32_bxor(bit32_rrotate(e, 6), bit32_rrotate(e, 11), bit32_rrotate(e, 25))
        local ch = bit32_bxor(bit32_band(e, f), bit32_band(bit32_bnot(e), g))
        local temp1 = (h + S1 + ch + K[t + 1] + w[t]) % 0x100000000

        local S0 = bit32_bxor(bit32_rrotate(a, 2), bit32_rrotate(a, 13), bit32_rrotate(a, 22))
        local maj = bit32_bxor(bit32_band(a, b), bit32_band(a, c), bit32_band(b, c))

        h = g
        g = f
        f = e
        e = (d + temp1) % 0x100000000
        d = c
        c = b
        b = a
        a = (temp1 + (S0 + maj) % 0x100000000) % 0x100000000
    end

    h1 = (h1 + a) % 0x100000000
    h2 = (h2 + b) % 0x100000000
    h3 = (h3 + c) % 0x100000000
    h4 = (h4 + d) % 0x100000000
    h5 = (h5 + e) % 0x100000000
    h6 = (h6 + f) % 0x100000000
    h7 = (h7 + g) % 0x100000000
    h8 = (h8 + h) % 0x100000000
  end

  -- convert to hex
  return h1, h2, h3, h4, h5, h6, h7, h8
end
