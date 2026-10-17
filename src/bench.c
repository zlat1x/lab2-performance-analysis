#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

/*
 * Independent per-element integer operations, repeated with an evolving state.
 * All arithmetic on uint32_t is defined modulo 2^32.
 * Keeping this function separate makes CPU profiles and assembly easier to read.
 */
#if defined(__GNUC__) || defined(__clang__)
__attribute__((noinline))
#endif
static void transform(uint32_t *restrict out,
                      const uint32_t *restrict a,
                      const uint32_t *restrict b,
                      size_t count, uint32_t round_number)
{
    for (size_t i = 0; i < count; ++i) {
        uint32_t mixed = a[i] ^ (b[i] >> 7);
        out[i] = (out[i] + mixed) * UINT32_C(1664525)
                 + UINT32_C(1013904223) + round_number;
    }
}

static int parse_positive(const char *value, size_t *result)
{
    char *end = NULL;
    errno = 0;
    unsigned long long parsed = strtoull(value, &end, 10);
    if (errno || end == value || *end != '\0' || parsed == 0 ||
        parsed > SIZE_MAX) {
        return -1;
    }
    *result = (size_t)parsed;
    return 0;
}

int main(int argc, char **argv)
{
    size_t count = 1048576;
    size_t rounds = 1000;
    if (argc > 3 || (argc > 1 && parse_positive(argv[1], &count)) ||
        (argc > 2 && parse_positive(argv[2], &rounds)) ||
        count > SIZE_MAX / sizeof(uint32_t) || rounds > UINT32_MAX) {
        fprintf(stderr, "Usage: %s [element_count] [rounds]\n", argv[0]);
        return 2;
    }

    uint32_t *a = malloc(count * sizeof(*a));
    uint32_t *b = malloc(count * sizeof(*b));
    uint32_t *out = calloc(count, sizeof(*out));
    if (!a || !b || !out) {
        fprintf(stderr, "Not enough memory\n");
        free(a);
        free(b);
        free(out);
        return 3;
    }

    for (size_t i = 0; i < count; ++i) {
        a[i] = (uint32_t)i * UINT32_C(2654435761) + UINT32_C(17);
        b[i] = ((uint32_t)i ^ UINT32_C(0x9e3779b9)) * UINT32_C(2246822519);
    }

    for (size_t round_number = 0; round_number < rounds; ++round_number) {
        transform(out, a, b, count, (uint32_t)round_number);
    }

    uint64_t checksum = 0;
    for (size_t i = 0; i < count; ++i) {
        checksum += out[i];
    }
    printf("elements=%zu rounds=%zu checksum=%" PRIu64 "\n",
           count, rounds, checksum);

    free(out);
    free(b);
    free(a);
    return 0;
}
