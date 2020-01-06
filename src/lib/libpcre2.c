#include <emscripten/emscripten.h>

#define PCRE2_CODE_UNIT_WIDTH 16
#include <pcre2.h>

// --------------------------------------------------------------------

static PCRE2_SIZE _lastErrorOffset = 0;

EMSCRIPTEN_KEEPALIVE
PCRE2_SIZE lastErrorOffset()
{
  return _lastErrorOffset;
}

// --------------------------------------------------------------------

// EMSCRIPTEN_KEEPALIVE
// pcre2_match_data *match(
//     pcre2_code *code,
//     uint16_t *subject,
//     PCRE2_SIZE length,
//     PCRE2_SIZE offset)
// {
//   pcre2_match_data *result = pcre2_match_data_create_from_pattern(code, NULL);

//   pcre2_match(code, subject, length, offset, 0, result, NULL);

//   return result;
// }
