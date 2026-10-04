import test from 'node:test';
import assert from 'node:assert/strict';

test('Conway Engine: evaluates B3/S23 survival rule for blinker pattern', () => {
  // Horizontal blinker (size 3)
  const grid = [
    [false, false, false],
    [true,  true,  true ],
    [false, false, false]
  ];

  const getNeighbors = (g, r, c) => {
    let count = 0;
    for (let dr = -1; dr <= 1; dr++) {
      for (let dc = -1; dc <= 1; dc++) {
        if (dr === 0 && dc === 0) continue;
        const nr = r + dr;
        const nc = c + dc;
        if (nr >= 0 && nr < 3 && nc >= 0 && nc < 3 && g[nr][nc]) {
          count++;
        }
      }
    }
    return count;
  };

  // Center cell [1,1] has 2 live neighbors -> survives
  assert.equal(getNeighbors(grid, 1, 1), 2);
  // Top center [0,1] has 3 live neighbors -> becomes alive (B3)
  assert.equal(getNeighbors(grid, 0, 1), 3);
  // Left cell [1,0] has 1 live neighbor -> dies (underpopulation)
  assert.equal(getNeighbors(grid, 1, 0), 1);
});
