## Colors

```dart
// Brand
primary:     Color(0xFF0E5C5C)  // deep teal — buttons, accents, pins
primaryDeep: Color(0xFF0A4747)  // hero gradients, dark teal
primarySoft: Color(0xFFE8F2F1)  // teal tints, badge backgrounds

accent:     Color(0xFFD88A4E)   // warm sand — Mediterranean accent, quote cards
accentSoft: Color(0xFFFBEFE2)   // sand tint

// Ink (text)
ink:  Color(0xFF0E1A1F)  // primary text
ink2: Color(0xFF3F5660)  // secondary text, descriptions
ink3: Color(0xFF7C8C92)  // captions, placeholders, timestamps

// Surface
paper: Color(0xFFFBFAF7)  // warm off-white — scaffold background, bottom sheets
card:  Color(0xFFFFFFFF)  // card surfaces
line:  Color(0xFFE7ECEC)  // borders, dividers

// Semantic
ok:    Color(0xFF1F9D6E)  // available / success / online dot
star:  Color(0xFFE0A82E)  // rating stars
error: Color(0xFFD93025)
```

## Typography

```dart
// Display / UI — Plus Jakarta Sans (google_fonts)
AppTheme.light  // text theme applies Plus Jakarta Sans globally
GoogleFonts.plusJakartaSans(...)  // use directly for custom sizes

// Prices / codes / numerics — JetBrains Mono
AppTheme.price(size: 16)                       // primary teal price
AppTheme.price(size: 16, color: AppColors.ink) // dark price
AppTheme.mono(size: 11)                        // secondary mono label
GoogleFonts.jetBrainsMono(...)                 // use directly
```

## Layout Conventions

- Cards: `color: AppColors.card`, `borderRadius: 18`, `border: Border.all(color: AppColors.line)`, two-layer box shadow
- Bottom sheets: `color: AppColors.paper`, `borderRadius: 24` top, drag handle `38×4 / AppColors.line`
- Buttons: filled = `AppColors.primary`, outlined = `AppColors.card + AppColors.line` border
- Category chips: active = `AppColors.primary` fill + teal shadow, inactive = `AppColors.card + AppColors.line` border
- Price markers on map: active = `AppColors.primary` fill, inactive = `AppColors.card + primary` border, JetBrains Mono label
- Bottom nav: `AppColors.card` bg, top border `AppColors.line`, active icon/label = `AppColors.primary`
- Available dot: `6×6` circle `AppColors.ok`

## ServiceCard

- Width: 280, padding 12 all sides
- Photo thumb: `84×84`, `borderRadius 14`, placeholder uses `AppColors.primarySoft`
- Price: JetBrains Mono `16/bold`, unit suffix `11/w500/ink3`
- Currency: EUR (€) — never $ in this app
