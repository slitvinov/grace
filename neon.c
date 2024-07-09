#include "arm_neon.h"
#include <stdio.h>
int main() {
  int i;
  uint8_t output[16],
      input[16] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
  uint8x16_t data, three;
  data = vld1q_u8(input);
  three = vmovq_n_u8(3);
  data = vaddq_u8(data, three);
  vst1q_u8(output, data);
  for (i = 0; i < 16; i++)
    printf("%02d %02d\n", input[i], output[i]);
}
