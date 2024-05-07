import { test, expect } from "bun:test";
import { Signal } from "."


test("Signal", () => {
  const signal = new Signal<number>()
  let result = 0
  const listener = (arg: number) => {
    result = arg
  }

  signal.on(listener)
  signal.emit(42)
  expect(result).toBe(42)

  signal.off(listener)
  expect(signal.listenerCount).toBe(0)

  signal.emit(43)
  expect(result).toBe(42)
})
