import { assertEquals } from "jsr:@std/assert";
import { add } from "./main.ts";

Deno.test(function addTest() {
  const a = 5;
  assertEquals(a, 5);
});
