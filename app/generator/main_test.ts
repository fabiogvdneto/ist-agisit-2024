import { assertEquals } from "jsr:@std/assert";

Deno.test(function addTest() {
  const a = 5;
  assertEquals(a, 5);
});
