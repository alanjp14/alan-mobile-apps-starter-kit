// ============================================================================
// Alan Mobile Design System (AMDS) v1.0
// Jetpack Compose theme. Generated from tokens/tokens.json.
//
// Usage:
//   setContent { AmdsTheme { App() } }
//
// Access semantic tokens:
//   AmdsTheme.colors.textSecondary
//   AmdsTheme.spacing.md
//   AmdsTheme.radius.lg
//   AmdsTheme.elevation.level3
// ============================================================================

package com.alan.amds.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.LineHeightStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// ---------------------------------------------------------------------------
// Raw palette
// ---------------------------------------------------------------------------
object AmdsPalette {
    val Green50 = Color(0xFFF0FDF4)
    val Green100 = Color(0xFFDCFCE7)
    val Green200 = Color(0xFFBBF7D0)
    val Green300 = Color(0xFF86EFAC)
    val Green400 = Color(0xFF4ADE80)
    val Green500 = Color(0xFF22C55E)
    val Green600 = Color(0xFF16A34A)
    val Green700 = Color(0xFF15803D)
    val Green800 = Color(0xFF166534)
    val Green900 = Color(0xFF14532D)
    val Green950 = Color(0xFF052E16)

    val Neutral0 = Color(0xFFFFFFFF)
    val Neutral50 = Color(0xFFF8FAFC)
    val Neutral100 = Color(0xFFF1F5F9)
    val Neutral200 = Color(0xFFE2E8F0)
    val Neutral300 = Color(0xFFCBD5E1)
    val Neutral400 = Color(0xFF94A3B8)
    val Neutral500 = Color(0xFF64748B)
    val Neutral600 = Color(0xFF475569)
    val Neutral700 = Color(0xFF334155)
    val Neutral800 = Color(0xFF1E293B)
    val Neutral900 = Color(0xFF0F172A)
    val Neutral950 = Color(0xFF020617)

    val Amber400 = Color(0xFFFBBF24)
    val Amber500 = Color(0xFFF59E0B)
    val Amber600 = Color(0xFFD97706)
    val Red400 = Color(0xFFF87171)
    val Red500 = Color(0xFFEF4444)
    val Red600 = Color(0xFFDC2626)
    val Sky400 = Color(0xFF38BDF8)
    val Sky500 = Color(0xFF0EA5E9)
    val Sky600 = Color(0xFF0284C7)
}

// ---------------------------------------------------------------------------
// Semantic color set (theme-aware)
// ---------------------------------------------------------------------------
@Immutable
data class AmdsColors(
    val primary: Color,
    val primaryHover: Color,
    val primaryPressed: Color,
    val primaryContainer: Color,
    val onPrimary: Color,
    val onPrimaryContainer: Color,
    val secondary: Color,
    val background: Color,
    val onBackground: Color,
    val surface: Color,
    val surfaceVariant: Color,
    val onSurface: Color,
    val onSurfaceVariant: Color,
    val textPrimary: Color,
    val textSecondary: Color,
    val textTertiary: Color,
    val textDisabled: Color,
    val textLink: Color,
    val border: Color,
    val borderStrong: Color,
    val borderFocus: Color,
    val divider: Color,
    val success: Color,
    val successContainer: Color,
    val warning: Color,
    val warningContainer: Color,
    val danger: Color,
    val dangerContainer: Color,
    val info: Color,
    val infoContainer: Color,
    val skeletonBase: Color,
    val skeletonSheen: Color,
    val scrim: Color,
    val isDark: Boolean,
)

val AmdsLightColors = AmdsColors(
    primary = AmdsPalette.Green600,
    primaryHover = AmdsPalette.Green700,
    primaryPressed = AmdsPalette.Green800,
    primaryContainer = AmdsPalette.Green100,
    onPrimary = AmdsPalette.Neutral0,
    onPrimaryContainer = AmdsPalette.Green900,
    secondary = AmdsPalette.Green500,
    background = AmdsPalette.Neutral50,
    onBackground = AmdsPalette.Neutral900,
    surface = AmdsPalette.Neutral0,
    surfaceVariant = AmdsPalette.Neutral100,
    onSurface = AmdsPalette.Neutral900,
    onSurfaceVariant = AmdsPalette.Neutral500,
    textPrimary = AmdsPalette.Neutral900,
    textSecondary = AmdsPalette.Neutral500,
    textTertiary = AmdsPalette.Neutral400,
    textDisabled = AmdsPalette.Neutral300,
    textLink = AmdsPalette.Green700,
    border = AmdsPalette.Neutral200,
    borderStrong = AmdsPalette.Neutral300,
    borderFocus = AmdsPalette.Green600,
    divider = AmdsPalette.Neutral200,
    success = AmdsPalette.Green600,
    successContainer = AmdsPalette.Green50,
    warning = AmdsPalette.Amber600,
    warningContainer = Color(0xFFFFFBEB),
    danger = AmdsPalette.Red600,
    dangerContainer = Color(0xFFFEF2F2),
    info = AmdsPalette.Sky600,
    infoContainer = Color(0xFFF0F9FF),
    skeletonBase = AmdsPalette.Neutral200,
    skeletonSheen = AmdsPalette.Neutral100,
    scrim = Color(0x7A0F172A),
    isDark = false,
)

val AmdsDarkColors = AmdsColors(
    primary = AmdsPalette.Green400,
    primaryHover = AmdsPalette.Green300,
    primaryPressed = AmdsPalette.Green200,
    primaryContainer = AmdsPalette.Green900,
    onPrimary = AmdsPalette.Green950,
    onPrimaryContainer = AmdsPalette.Green100,
    secondary = AmdsPalette.Green500,
    background = AmdsPalette.Neutral950,
    onBackground = AmdsPalette.Neutral50,
    surface = AmdsPalette.Neutral900,
    surfaceVariant = AmdsPalette.Neutral800,
    onSurface = AmdsPalette.Neutral50,
    onSurfaceVariant = AmdsPalette.Neutral400,
    textPrimary = AmdsPalette.Neutral50,
    textSecondary = AmdsPalette.Neutral400,
    textTertiary = AmdsPalette.Neutral500,
    textDisabled = AmdsPalette.Neutral700,
    textLink = AmdsPalette.Green400,
    border = AmdsPalette.Neutral700,
    borderStrong = AmdsPalette.Neutral600,
    borderFocus = AmdsPalette.Green400,
    divider = AmdsPalette.Neutral800,
    success = AmdsPalette.Green400,
    successContainer = Color(0x2922C55E),
    warning = AmdsPalette.Amber400,
    warningContainer = Color(0x29F59E0B),
    danger = AmdsPalette.Red400,
    dangerContainer = Color(0x29EF4444),
    info = AmdsPalette.Sky400,
    infoContainer = Color(0x290EA5E9),
    skeletonBase = AmdsPalette.Neutral800,
    skeletonSheen = AmdsPalette.Neutral700,
    scrim = Color(0xA3020617),
    isDark = true,
)

// ---------------------------------------------------------------------------
// Spacing, radius, elevation
// ---------------------------------------------------------------------------
@Immutable
data class AmdsSpacing(
    val none: androidx.compose.ui.unit.Dp = 0.dp,
    val xs: androidx.compose.ui.unit.Dp = 4.dp,
    val sm: androidx.compose.ui.unit.Dp = 8.dp,
    val ms: androidx.compose.ui.unit.Dp = 12.dp,
    val md: androidx.compose.ui.unit.Dp = 16.dp,
    val lm: androidx.compose.ui.unit.Dp = 20.dp,
    val lg: androidx.compose.ui.unit.Dp = 24.dp,
    val xl: androidx.compose.ui.unit.Dp = 32.dp,
    val xxl: androidx.compose.ui.unit.Dp = 40.dp,
    val xxxl: androidx.compose.ui.unit.Dp = 48.dp,
    val huge: androidx.compose.ui.unit.Dp = 64.dp,
)

@Immutable
data class AmdsRadius(
    val xs: androidx.compose.ui.unit.Dp = 4.dp,
    val sm: androidx.compose.ui.unit.Dp = 8.dp,
    val md: androidx.compose.ui.unit.Dp = 12.dp,
    val lg: androidx.compose.ui.unit.Dp = 16.dp,
    val xl: androidx.compose.ui.unit.Dp = 24.dp,
    val xxl: androidx.compose.ui.unit.Dp = 32.dp,
)

@Immutable
data class AmdsElevation(
    val level1: androidx.compose.ui.unit.Dp = 1.dp,
    val level2: androidx.compose.ui.unit.Dp = 3.dp,
    val level3: androidx.compose.ui.unit.Dp = 6.dp,
    val level4: androidx.compose.ui.unit.Dp = 12.dp,
    val level5: androidx.compose.ui.unit.Dp = 24.dp,
)

object AmdsMotion {
    const val INSTANT = 100
    const val FAST = 150
    const val BASE = 200
    const val MODERATE = 250
    const val SLOW = 300
    const val SLOWER = 400
    val StandardEasing = androidx.compose.animation.core.CubicBezierEasing(0.2f, 0f, 0f, 1f)
    val DecelerateEasing = androidx.compose.animation.core.CubicBezierEasing(0f, 0f, 0f, 1f)
    val AccelerateEasing = androidx.compose.animation.core.CubicBezierEasing(0.3f, 0f, 1f, 1f)
    val SpringEasing = androidx.compose.animation.core.CubicBezierEasing(0.34f, 1.56f, 0.64f, 1f)
}

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------
private val Inter = FontFamily.Default // replace with Inter FontFamily once bundled

private fun style(size: Int, line: Int, weight: FontWeight, tracking: Double = 0.0) = TextStyle(
    fontFamily = Inter,
    fontSize = size.sp,
    lineHeight = line.sp,
    fontWeight = weight,
    letterSpacing = tracking.sp,
    lineHeightStyle = LineHeightStyle(
        alignment = LineHeightStyle.Alignment.Center,
        trim = LineHeightStyle.Trim.None,
    ),
)

val AmdsTypographyM3 = Typography(
    displayLarge = style(36, 44, FontWeight.Bold, -0.5),
    displayMedium = style(32, 40, FontWeight.Bold, -0.5),
    displaySmall = style(28, 36, FontWeight.Bold, -0.25),
    headlineLarge = style(24, 32, FontWeight.SemiBold, -0.25),
    headlineMedium = style(20, 28, FontWeight.SemiBold),
    headlineSmall = style(18, 26, FontWeight.SemiBold),
    titleLarge = style(16, 24, FontWeight.SemiBold),
    titleMedium = style(14, 20, FontWeight.Medium, 0.1),
    titleSmall = style(13, 18, FontWeight.Medium),
    bodyLarge = style(16, 24, FontWeight.Normal),
    bodyMedium = style(14, 20, FontWeight.Normal),
    bodySmall = style(13, 18, FontWeight.Normal),
    labelLarge = style(14, 16, FontWeight.Medium, 0.1),
    labelMedium = style(12, 16, FontWeight.Medium, 0.5),
    labelSmall = style(11, 16, FontWeight.SemiBold, 0.8),
)

val AmdsShapes = Shapes(
    extraSmall = RoundedCornerShape(4.dp),
    small = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(12.dp),
    large = RoundedCornerShape(16.dp),
    extraLarge = RoundedCornerShape(24.dp),
)

// ---------------------------------------------------------------------------
// CompositionLocals + theme entry point
// ---------------------------------------------------------------------------
private val LocalAmdsColors = staticCompositionLocalOf { AmdsLightColors }
private val LocalAmdsSpacing = staticCompositionLocalOf { AmdsSpacing() }
private val LocalAmdsRadius = staticCompositionLocalOf { AmdsRadius() }
private val LocalAmdsElevation = staticCompositionLocalOf { AmdsElevation() }

object AmdsTheme {
    val colors: AmdsColors
        @Composable @ReadOnlyComposable get() = LocalAmdsColors.current
    val spacing: AmdsSpacing
        @Composable @ReadOnlyComposable get() = LocalAmdsSpacing.current
    val radius: AmdsRadius
        @Composable @ReadOnlyComposable get() = LocalAmdsRadius.current
    val elevation: AmdsElevation
        @Composable @ReadOnlyComposable get() = LocalAmdsElevation.current
}

private fun AmdsColors.toM3() = if (isDark) {
    darkColorScheme(
        primary = primary, onPrimary = onPrimary,
        primaryContainer = primaryContainer, onPrimaryContainer = onPrimaryContainer,
        secondary = secondary, background = background, onBackground = onBackground,
        surface = surface, onSurface = onSurface,
        surfaceVariant = surfaceVariant, onSurfaceVariant = onSurfaceVariant,
        error = danger, outline = border, outlineVariant = divider, scrim = scrim,
    )
} else {
    lightColorScheme(
        primary = primary, onPrimary = onPrimary,
        primaryContainer = primaryContainer, onPrimaryContainer = onPrimaryContainer,
        secondary = secondary, background = background, onBackground = onBackground,
        surface = surface, onSurface = onSurface,
        surfaceVariant = surfaceVariant, onSurfaceVariant = onSurfaceVariant,
        error = danger, outline = border, outlineVariant = divider, scrim = scrim,
    )
}

@Composable
fun AmdsTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    val colors = if (darkTheme) AmdsDarkColors else AmdsLightColors
    CompositionLocalProvider(
        LocalAmdsColors provides colors,
        LocalAmdsSpacing provides AmdsSpacing(),
        LocalAmdsRadius provides AmdsRadius(),
        LocalAmdsElevation provides AmdsElevation(),
    ) {
        MaterialTheme(
            colorScheme = colors.toM3(),
            typography = AmdsTypographyM3,
            shapes = AmdsShapes,
            content = content,
        )
    }
}
