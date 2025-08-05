# AI Service Limits Configuration

## Overview

This system addresses the concern about hardcoded AI service limits by implementing a flexible and maintainable approach to handle different AI services with varying capabilities.

## Problem Solved

Previously, the app used a hardcoded limit of 3000 words for all AI services. This was problematic because:

- Different AI services have different context windows and limits
- OpenAI GPT-3.5-turbo has different limits than Google Gemini
- Hardcoded values make the app fragile when AI services update their limits
- No easy way to adjust limits without code changes

## Solution Architecture

### 1. Centralized Configuration (`AILimitsConfig`)

All AI service limits are now centralized in `lib/data/services/ai/ai_limits_config.dart`:

```dart
static const Map<String, AIServiceLimits> _serviceLimits = {
  'OpenAI GPT': AIServiceLimits(
    maxWords: 2000,
    maxCharacters: 8000,
    description: 'Conservative limit for GPT models',
  ),
  'Google Gemini': AIServiceLimits(
    maxWords: 8000,
    maxCharacters: 30000,
    description: 'Higher context window for Gemini',
  ),
};
```

### 2. Dynamic Limit Detection

The UI now dynamically shows the current service's limits:

- Word count display updates based on selected service
- Validation changes when switching between services
- Service-specific limit information shown to users

### 3. Fallback Mechanisms

Multiple layers of fallback ensure robustness:

1. **Primary**: Centralized config in `AILimitsConfig`
2. **Secondary**: Service-specific defaults in individual service classes
3. **Tertiary**: Global default of 3000 words

## Current Limits

### OpenAI GPT

- **Words**: 2000 (conservative for reliable generation)
- **Characters**: 8000
- **Reasoning**: GPT-3.5-turbo works best with shorter, focused prompts

### Google Gemini

- **Words**: 8000 (leverages larger context window)
- **Characters**: 30000
- **Reasoning**: Gemini can handle longer content effectively

## Benefits

### 1. **Maintainability**

- Single file to update all service limits
- No need to hunt through multiple files
- Clear documentation of reasoning for each limit

### 2. **Flexibility**

- Easy to add new AI services
- Simple to adjust limits based on real-world performance
- Can set different limits for different models of the same service

### 3. **User Experience**

- Users see accurate limits for their selected service
- Real-time validation based on current service
- Clear feedback about service capabilities

### 4. **Robustness**

- Multiple fallback layers prevent app crashes
- Graceful handling of service changes
- Future-proof against API updates

## Adding New AI Services

To add a new AI service with custom limits:

1. **Add to AILimitsConfig**:

```dart
'New Service Name': AIServiceLimits(
  maxWords: 5000,
  maxCharacters: 20000,
  description: 'Custom limits for new service',
),
```

2. **Service automatically gets the limits** - no additional code needed in the service class.

## Updating Limits

To adjust limits for existing services, simply update the values in `AILimitsConfig`. The entire app will immediately use the new limits without any other changes.

## API Consultation

Currently, there's no standard API to query AI service limits dynamically. This solution provides:

- **Reasonable defaults** based on documented service capabilities
- **Easy updates** when services change their limits
- **Service-specific optimization** for best user experience

The limits are set conservatively to ensure reliable operation while maximizing the content users can provide.

## Future Enhancements

Potential future improvements:

1. **Remote configuration** - fetch limits from a server
2. **Model-specific limits** - different limits for different models of the same service
3. **Usage-based limits** - adjust based on user's API quota
4. **Dynamic testing** - automatically test service limits periodically

## Technical Implementation

The system uses:

- **Strategy pattern** for service-specific behavior
- **Configuration-driven design** for maintainability
- **Graceful degradation** for robustness
- **Type-safe configuration** with compile-time validation
