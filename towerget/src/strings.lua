local function shallowCopy(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  return copy
end

local default = {
  S_LANG = 'English',
  S_TITLE = 'Press [enter] to play or [esc] to quit.',
  S_PAUSE = 'PAUSE'
}

S = {
  en = shallowCopy(default),
  es = shallowCopy(default)
}

-- es
S.es.S_LANG = 'Español'
S.es.S_TITLE = 'Presiona [enter] para jugar o [esc] para salir.'
S.es.S_PAUSE = 'PAUSA'
