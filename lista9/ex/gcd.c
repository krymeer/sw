#include <stdio.h>

int main(void) {
  int a = 10, b = 24, acc = 0;

  // Load, Subt
  loop_start:
    acc = a - b;
    if (acc == 0) {
      goto end;
    } else if (acc < 0) {
      goto less;
    } else {
      goto greater;
    }

  // Subt, Store
  less:
    b -= a;
    goto loop_start;

  // Subt, Store
  greater:
    a -= b;
    goto loop_start;

  // Load, Output
  end:
    printf("%d\n", a);

  return 0;
}