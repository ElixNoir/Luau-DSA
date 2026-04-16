--- Author: COMT

--[[

  AES

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Constants

local Nb = 4
local InvSubstitutionBox = {
  0x53, 0x09, 0x6B, 0xD6, 0x30, 0x36, 0xA6, 0x38, 0xC0, 0x40, 0xA4, 0x9F, 0x82, 0xF4, 0xD8, 0xFC,
  0x7D, 0xE4, 0x39, 0x83, 0x9C, 0x2F, 0x4F, 0x88, 0x34, 0x8F, 0x43, 0x44, 0xC5, 0xDF, 0xEA, 0xCC,
  0x55, 0x7C, 0x95, 0x32, 0xA7, 0xC3, 0x23, 0x3D, 0xEF, 0x4C, 0x96, 0x0B, 0x42, 0xFB, 0xC4, 0x4E,
  0x08, 0x2E, 0xA2, 0x67, 0x28, 0xDA, 0x24, 0xB3, 0x77, 0x5C, 0xA3, 0x49, 0x6E, 0x8C, 0xD2, 0x25,
  0x73, 0xF9, 0xF7, 0x65, 0x87, 0x69, 0x99, 0x16, 0xD5, 0xA5, 0x5D, 0xCD, 0x5E, 0x66, 0xB7, 0x93,
  0x6D, 0x71, 0x48, 0x51, 0xFE, 0xEE, 0xBA, 0xDB, 0x5F, 0x15, 0x46, 0x58, 0xA8, 0x8E, 0x9E, 0x85,
  0x91, 0xD9, 0xAC, 0x00, 0x8D, 0xBD, 0xD4, 0x0A, 0xF8, 0xE5, 0x59, 0x05, 0xB9, 0xB4, 0x45, 0x06,
  0xD1, 0x2C, 0x1E, 0x90, 0xCB, 0x3F, 0x0F, 0x02, 0xC2, 0xB0, 0xBE, 0x03, 0x01, 0x13, 0x8B, 0x6C,
  0x3A, 0x92, 0x11, 0x41, 0x50, 0x68, 0xDD, 0xEB, 0x98, 0xF3, 0xD0, 0xCF, 0xF1, 0xB5, 0xE7, 0x74,
  0x97, 0xAD, 0x75, 0x22, 0xE8, 0xAE, 0x35, 0x86, 0xE3, 0xFA, 0x37, 0xE9, 0x1C, 0x76, 0xE0, 0x6F,
  0x47, 0xF2, 0x1A, 0x72, 0x1D, 0x29, 0xC6, 0x8A, 0x70, 0xB8, 0x63, 0x0E, 0xAB, 0x18, 0xBF, 0x1B,
  0xFD, 0x57, 0x3E, 0x4B, 0xC7, 0xD3, 0x7A, 0x20, 0x9B, 0xDC, 0xC1, 0xFF, 0x79, 0xCE, 0x5B, 0xF5,
  0x1F, 0xDE, 0xA9, 0x33, 0x89, 0x07, 0xC8, 0x31, 0xB2, 0x12, 0x10, 0x5A, 0x27, 0x81, 0xED, 0x60,
  0x61, 0x52, 0x80, 0xAA, 0x19, 0xB6, 0x4A, 0x0D, 0x2D, 0xE6, 0x7B, 0xA0, 0x94, 0xCA, 0x9D, 0xF0,
  0xA1, 0xE1, 0x3B, 0x4D, 0xAF, 0x2A, 0xF6, 0xB1, 0xC9, 0xEC, 0xBC, 0x3C, 0x84, 0x54, 0x9A, 0x62,
  0x17, 0x2B, 0x04, 0x7F, 0xBB, 0x78, 0xD7, 0x26, 0xE2, 0x6A, 0x14, 0x64, 0x56, 0x21, 0x0C, 0x7E
}
local Rcon = {
  0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1B, 0x36
}
local SubstitutionBox = {
  0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
  0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
  0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
  0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
  0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x16,
  0x84, 0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58,
  0xcf, 0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f,
  0xa8, 0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3,
  0xd2, 0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19,
  0x73, 0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b,
  0xdb, 0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4,
  0x79, 0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae,
  0x08, 0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b,
  0x8a, 0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d,
  0x9e, 0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28,
  0xdf, 0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb
}


-- -- Helpers

local bit32_band = bit32.band
local bit32_bxor = bit32.bxor

local table_create = table.create
local table_move = table.move

local function mul(a: number, b: number): number
  local result = 0
  while b > 0 do
    if bit32_band(b, 1) ~= 0 then
      result = bit32_bxor(result, a)
    end
    a *= 2
    if a >= 0x100 then
      a = bit32_bxor(a, 0x11B)
    end
    a = bit32_band(a, 0xFF)
    b = b // 2
  end
  return result
end

-- -- Key expansion

local function expandKey(key: {number}): ({number}, number)
  local Nk = #key // 4
  local nr = Nk + 6

  local totalWords = Nb * (nr + 1)
  local w = table_create(totalWords * 4, 0)

  table_move(key, 1, #key, 1, w)

  for i = Nk + 1, totalWords do
    local i4 = (i - 1) * 4 + 1
    local prev4 = (i - 2) * 4 + 1

    local t0 = w[prev4]
    local t1 = w[prev4 + 1]
    local t2 = w[prev4 + 2]
    local t3 = w[prev4 + 3]

    if i % Nk == 1 then
      t0, t1, t2, t3 = t1, t2, t3, t0

      t0 = SubstitutionBox[t0 + 1]
      t1 = SubstitutionBox[t1 + 1]
      t2 = SubstitutionBox[t2 + 1]
      t3 = SubstitutionBox[t3 + 1]

      t0 = bit32_bxor(t0, Rcon[(i - 1) // Nk])
    elseif Nk > 6 and i % Nk == 5 then
      t0 = SubstitutionBox[t0 + 1]
      t1 = SubstitutionBox[t1 + 1]
      t2 = SubstitutionBox[t2 + 1]
      t3 = SubstitutionBox[t3 + 1]
    end

    local back4 = (i - Nk - 1) * 4 + 1

    w[i4] = bit32_bxor(w[back4], t0)
    w[i4 + 1] = bit32_bxor(w[back4 + 1], t1)
    w[i4 + 2] = bit32_bxor(w[back4 + 2], t2)
    w[i4 + 3] = bit32_bxor(w[back4 + 3], t3)
  end

  return w, nr
end

-- -- Encrypt block

function Module.encryptBlock(key: {number},
  b1: number, b2: number, b3: number, b4: number,
  b5: number, b6: number, b7: number, b8: number,
  b9: number, b10: number, b11: number, b12: number,
  b13: number, b14: number, b15: number, b16: number
): (number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number)
  local w, nr = expandKey(key)

  // Add round key

  local w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16 = 
    w[1], w[2], w[3], w[4],
    w[5], w[6], w[7], w[8],
    w[9], w[10], w[11], w[12],
    w[13], w[14], w[15], w[16]
  
  b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 =
    bit32_bxor(b1, w1), bit32_bxor(b2, w2), bit32_bxor(b3, w3), bit32_bxor(b4, w4),
    bit32_bxor(b5, w5), bit32_bxor(b6, w6), bit32_bxor(b7, w7), bit32_bxor(b8, w8),
    bit32_bxor(b9, w9), bit32_bxor(b10, w10), bit32_bxor(b11, w11), bit32_bxor(b12, w12),
    bit32_bxor(b13, w13), bit32_bxor(b14, w14), bit32_bxor(b15, w15), bit32_bxor(b16, w16)

  for round = 1, nr - 1 do
    // Substitution

    b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 = 
      SubstitutionBox[b1 + 1], SubstitutionBox[b2 + 1], SubstitutionBox[b3 + 1], SubstitutionBox[b4 + 1],
      SubstitutionBox[b5 + 1], SubstitutionBox[b6 + 1], SubstitutionBox[b7 + 1], SubstitutionBox[b8 + 1],
      SubstitutionBox[b9 + 1], SubstitutionBox[b10 + 1], SubstitutionBox[b11 + 1], SubstitutionBox[b12 + 1],
      SubstitutionBox[b13 + 1], SubstitutionBox[b14 + 1], SubstitutionBox[b15 + 1], SubstitutionBox[b16 + 1]


    // Shift rows

    b2, b6, b10, b14 = b6, b10, b14, b2
    b3, b7, b11, b15 = b11, b15, b3, b7
    b4, b8, b12, b16 = b16, b4, b8, b12


    // Mix columns

    local a1, a2, a3, a4 = b1, b2, b3, b4
    b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 =
      bit32_bxor(mul(b1, 2), mul(b2, 3), b3, b4), bit32_bxor(b1, mul(b2, 2), mul(b3, 3), b4), bit32_bxor(b1, b2, mul(b3, 2), mul(b4, 3)), bit32_bxor(mul(b1, 3), b2, b3, mul(b4, 2)),
      bit32_bxor(mul(b5, 2), mul(b6, 3), b7, b8), bit32_bxor(b5, mul(b6, 2), mul(b7, 3), b8), bit32_bxor(b5, b6, mul(b7, 2), mul(b8, 3)), bit32_bxor(mul(b5, 3), b6, b7, mul(b8, 2)),
      bit32_bxor(mul(b9, 2), mul(b10, 3), b11, b12), bit32_bxor(b9, mul(b10, 2), mul(b11, 3), b12), bit32_bxor(b9, b10, mul(b11, 2), mul(b12, 3)), bit32_bxor(mul(b9, 3), b10, b11, mul(b12, 2)),
      bit32_bxor(mul(b13, 2), mul(b14, 3), b15, b16), bit32_bxor(b13, mul(b14, 2), mul(b15, 3), b16), bit32_bxor(b13, b14, mul(b15, 2), mul(b16, 3)), bit32_bxor(mul(b13, 3), b14, b15, mul(b16, 2))


    // Add round key

    local offset = round * 16
    w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16 = 
      w[offset + 1], w[offset + 2], w[offset + 3], w[offset + 4],
      w[offset + 5], w[offset + 6], w[offset + 7], w[offset + 8],
      w[offset + 9], w[offset + 10], w[offset + 11], w[offset + 12],
      w[offset + 13], w[offset + 14], w[offset + 15], w[offset + 16]
  
    b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 =
      bit32_bxor(b1, w1), bit32_bxor(b2, w2), bit32_bxor(b3, w3), bit32_bxor(b4, w4),
      bit32_bxor(b5, w5), bit32_bxor(b6, w6), bit32_bxor(b7, w7), bit32_bxor(b8, w8),
      bit32_bxor(b9, w9), bit32_bxor(b10, w10), bit32_bxor(b11, w11), bit32_bxor(b12, w12),
      bit32_bxor(b13, w13), bit32_bxor(b14, w14), bit32_bxor(b15, w15), bit32_bxor(b16, w16)
  end

  // Substitution

  b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 =
    SubstitutionBox[b1 + 1], SubstitutionBox[b2 + 1], SubstitutionBox[b3 + 1], SubstitutionBox[b4 + 1],
    SubstitutionBox[b5 + 1], SubstitutionBox[b6 + 1], SubstitutionBox[b7 + 1], SubstitutionBox[b8 + 1],
    SubstitutionBox[b9 + 1], SubstitutionBox[b10 + 1], SubstitutionBox[b11 + 1], SubstitutionBox[b12 + 1],
    SubstitutionBox[b13 + 1], SubstitutionBox[b14 + 1], SubstitutionBox[b15 + 1], SubstitutionBox[b16 + 1]


  // Shift rows

  b2, b6, b10, b14 = b6, b10, b14, b2
  b3, b7, b11, b15 = b11, b15, b3, b7
  b4, b8, b12, b16 = b16, b4, b8, b12


  // Add round key

  local offset = nr * 16
  w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16 = 
    w[offset + 1], w[offset + 2], w[offset + 3], w[offset + 4],
    w[offset + 5], w[offset + 6], w[offset + 7], w[offset + 8],
    w[offset + 9], w[offset + 10], w[offset + 11], w[offset + 12],
    w[offset + 13], w[offset + 14], w[offset + 15], w[offset + 16]

  b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 =
    bit32_bxor(b1, w1), bit32_bxor(b2, w2), bit32_bxor(b3, w3), bit32_bxor(b4, w4),
    bit32_bxor(b5, w5), bit32_bxor(b6, w6), bit32_bxor(b7, w7), bit32_bxor(b8, w8),
    bit32_bxor(b9, w9), bit32_bxor(b10, w10), bit32_bxor(b11, w11), bit32_bxor(b12, w12),
    bit32_bxor(b13, w13), bit32_bxor(b14, w14), bit32_bxor(b15, w15), bit32_bxor(b16, w16)

  return b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16
end

-- -- Decrypt block

function Module.decryptBlock(key: {number},
  b1: number, b2: number, b3: number, b4: number,
  b5: number, b6: number, b7: number, b8: number,
  b9: number, b10: number, b11: number, b12: number,
  b13: number, b14: number, b15: number, b16: number
): (number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number)
  local w, nr = expandKey(key)

  // Add round key

  local offset = nr * 16
  local w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16 = 
    w[offset + 1], w[offset + 2], w[offset + 3], w[offset + 4],
    w[offset + 5], w[offset + 6], w[offset + 7], w[offset + 8],
    w[offset + 9], w[offset + 10], w[offset + 11], w[offset + 12],
    w[offset + 13], w[offset + 14], w[offset + 15], w[offset + 16]
  
  b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 =
    bit32_bxor(b1, w1), bit32_bxor(b2, w2), bit32_bxor(b3, w3), bit32_bxor(b4, w4),
    bit32_bxor(b5, w5), bit32_bxor(b6, w6), bit32_bxor(b7, w7), bit32_bxor(b8, w8),
    bit32_bxor(b9, w9), bit32_bxor(b10, w10), bit32_bxor(b11, w11), bit32_bxor(b12, w12),
    bit32_bxor(b13, w13), bit32_bxor(b14, w14), bit32_bxor(b15, w15), bit32_bxor(b16, w16)

  for round = nr - 1, 1, -1 do
    // Inverse shift rows

    b2, b6, b10, b14 = b14, b2, b6, b10
    b3, b7, b11, b15 = b11, b15, b3, b7
    b4, b8, b12, b16 = b8, b12, b16, b4


    // Inverse substitution

    b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 =
      InvSubstitutionBox[b1 + 1], InvSubstitutionBox[b2 + 1], InvSubstitutionBox[b3 + 1], InvSubstitutionBox[b4 + 1],
      InvSubstitutionBox[b5 + 1], InvSubstitutionBox[b6 + 1], InvSubstitutionBox[b7 + 1], InvSubstitutionBox[b8 + 1],
      InvSubstitutionBox[b9 + 1], InvSubstitutionBox[b10 + 1], InvSubstitutionBox[b11 + 1], InvSubstitutionBox[b12 + 1],
      InvSubstitutionBox[b13 + 1], InvSubstitutionBox[b14 + 1], InvSubstitutionBox[b15 + 1], InvSubstitutionBox[b16 + 1]


    // Add round key

    offset = round * 16
    w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16 = 
      w[offset + 1], w[offset + 2], w[offset + 3], w[offset + 4],
      w[offset + 5], w[offset + 6], w[offset + 7], w[offset + 8],
      w[offset + 9], w[offset + 10], w[offset + 11], w[offset + 12],
      w[offset + 13], w[offset + 14], w[offset + 15], w[offset + 16]

    b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 =
      bit32_bxor(b1, w1), bit32_bxor(b2, w2), bit32_bxor(b3, w3), bit32_bxor(b4, w4),
      bit32_bxor(b5, w5), bit32_bxor(b6, w6), bit32_bxor(b7, w7), bit32_bxor(b8, w8),
      bit32_bxor(b9, w9), bit32_bxor(b10, w10), bit32_bxor(b11, w11), bit32_bxor(b12, w12),
      bit32_bxor(b13, w13), bit32_bxor(b14, w14), bit32_bxor(b15, w15), bit32_bxor(b16, w16)


    // Inverse mix columns

    b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 =
      bit32_bxor(mul(a1, 14), mul(a2, 11), mul(a3, 13), mul(a4, 9)), bit32_bxor(mul(a1, 9), mul(a2, 14), mul(a3, 11), mul(a4, 13)), bit32_bxor(mul(a1, 13), mul(a2, 9), mul(a3, 14), mul(a4, 11)), bit32_bxor(mul(a1, 11), mul(a2, 13), mul(a3, 9), mul(a4, 14)),
      bit32_bxor(mul(b5, 14), mul(b6, 11), mul(b7, 13), mul(b8, 9)), bit32_bxor(mul(b5, 9), mul(b6, 14), mul(b7, 11), mul(b8, 13)), bit32_bxor(mul(b5, 13), mul(b6, 9), mul(b7, 14), mul(b8, 11)), bit32_bxor(mul(b5, 11), mul(b6, 13), mul(b7, 9), mul(b8, 14)),
      bit32_bxor(mul(b9, 14), mul(b10, 11), mul(b11, 13), mul(b12, 9)), bit32_bxor(mul(b9, 9), mul(b10, 14), mul(b11, 11), mul(b12, 13)), bit32_bxor(mul(b9, 13), mul(b10, 9), mul(b11, 14), mul(b12, 11)), bit32_bxor(mul(b9, 11), mul(b10, 13), mul(b11, 9), mul(b12, 14)),
      bit32_bxor(mul(b13, 14), mul(b14, 11), mul(b15, 13), mul(b16, 9)), bit32_bxor(mul(b13, 9), mul(b14, 14), mul(b15, 11), mul(b16, 13)), bit32_bxor(mul(b13, 13), mul(b14, 9), mul(b15, 14), mul(b16, 11)), bit32_bxor(mul(b13, 11), mul(b14, 13), mul(b15, 9), mul(b16, 14))
  end

  // Inverse shift rows
  b2, b6, b10, b14 = b14, b2, b6, b10
  b3, b7, b11, b15 = b11, b15, b3, b7
  b4, b8, b12, b16 = b8, b12, b16, b4


  // Inverse substitution
  b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 =
    InvSubstitutionBox[b1 + 1], InvSubstitutionBox[b2 + 1], InvSubstitutionBox[b3 + 1], InvSubstitutionBox[b4 + 1],
    InvSubstitutionBox[b5 + 1], InvSubstitutionBox[b6 + 1], InvSubstitutionBox[b7 + 1], InvSubstitutionBox[b8 + 1],
    InvSubstitutionBox[b9 + 1], InvSubstitutionBox[b10 + 1], InvSubstitutionBox[b11 + 1], InvSubstitutionBox[b12 + 1],
    InvSubstitutionBox[b13 + 1], InvSubstitutionBox[b14 + 1], InvSubstitutionBox[b15 + 1], InvSubstitutionBox[b16 + 1]


  // Add round key

  w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16 = 
    w[1], w[2], w[3], w[4],
    w[5], w[6], w[7], w[8],
    w[9], w[10], w[11], w[12],
    w[13], w[14], w[15], w[16]

  b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16 =
    bit32_bxor(b1, w1), bit32_bxor(b2, w2), bit32_bxor(b3, w3), bit32_bxor(b4, w4),
    bit32_bxor(b5, w5), bit32_bxor(b6, w6), bit32_bxor(b7, w7), bit32_bxor(b8, w8),
    bit32_bxor(b9, w9), bit32_bxor(b10, w10), bit32_bxor(b11, w11), bit32_bxor(b12, w12),
    bit32_bxor(b13, w13), bit32_bxor(b14, w14), bit32_bxor(b15, w15), bit32_bxor(b16, w16)
  
  return b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16
end


-- -- End

return Module
