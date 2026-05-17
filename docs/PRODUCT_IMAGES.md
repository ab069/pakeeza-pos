# Product images & animations

## What you see now (no extra files needed)

- **Pizza** — animated pizza-in-box (Small / Medium / Large scale in size picker)
- **Other categories** — animated emoji on gradient (burgers, wings, fries, etc.)
- **Product grid** — image area + name, fade-in animation
- **Cart** — small thumbnail per line

## Add your own photos (recommended)

Put PNG or JPG files here, then run `flutter run` again:

```
assets/images/products/
```

### Naming rules

| File | Shows on |
|------|----------|
| `c1_p1.png` | Category 1 (Special Flavours), product id 1 |
| `c3_p12_small.png` | Regular pizza product 12, **Small** size |
| `c3_p12_large.png` | Same product, **Large** size |
| `c4_p20.png` | Burgers, product id 20 |

- `c` = category id (1–8, same as database)
- `p` = product id (from menu seed order)
- Optional suffix: `_small`, `_medium`, `_large`, `_regular`

Category banner (optional):

```
assets/images/categories/cat_1.png
```

If a file is missing, the app uses the **animated illustration** automatically.

## Find product ids

Run the app → note category + product order (first pizza in Special = usually `c1_p1`).

Or check `lib/data/seed/menu_seed.dart` for id assignment.

## Tips for good photos

- Square images (~400×400 px)
- Transparent PNG for pizza-in-box shots
- Same style per category (all pizzas on red background, etc.)

## Animated Lottie (future)

To use `.json` Lottie files later, add package `lottie` and place files under `assets/lottie/`.
