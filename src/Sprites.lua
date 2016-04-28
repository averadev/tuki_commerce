---------------------------------------------------------------------------------
-- Tuki
-- Alberto Vera Espitia
-- GeekBucket 2016
---------------------------------------------------------------------------------

local Sprites = {}

Sprites.loading = {
  source = "img/sprLoading.png",
  frames = {width=64, height=64, numFrames=8},
  sequences = {
      { name = "stop", loopCount = 1, start = 1, count=1},
      { name = "play", time=1500, start = 1, count=8}
  }
}

return Sprites