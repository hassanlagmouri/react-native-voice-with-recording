# Publishing Guide

This guide will walk you through the process of publishing `react-native-voice-with-recording` to npm.

## Prerequisites

1. **npm account**: Create an account at [npmjs.com](https://www.npmjs.com)
2. **GitHub repository**: Push your code to GitHub (optional but recommended)
3. **Node.js and npm**: Make sure you have the latest versions installed

## Step 1: Prepare Your Package

### 1.1 Update package.json
Make sure to update the following fields in `package.json`:

```json
{
  "author": "Your Name <your.email@example.com>",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/yourusername/react-native-voice-with-recording.git"
  },
  "bugs": {
    "url": "https://github.com/yourusername/react-native-voice-with-recording/issues"
  },
  "homepage": "https://github.com/yourusername/react-native-voice-with-recording#readme"
}
```

### 1.2 Test Your Package Locally
```bash
# Build the package
npm run build

# Test the build output
node -e "console.log(require('./dist/index.js'))"
```

### 1.3 Check What Will Be Published
```bash
npm pack --dry-run
```

This will show you exactly which files will be included in your package.

## Step 2: Login to npm

```bash
npm login
```

Enter your npm username, password, and email when prompted.

## Step 3: Check Package Name Availability

```bash
npm search react-native-voice-with-recording
```

If the name is taken, you'll need to choose a different name in `package.json`.

## Step 4: Publish Your Package

### 4.1 First Time Publishing
```bash
npm publish
```

### 4.2 Publishing Updates
```bash
# Update version number
npm version patch  # for bug fixes (1.0.0 -> 1.0.1)
npm version minor  # for new features (1.0.0 -> 1.1.0)
npm version major  # for breaking changes (1.0.0 -> 2.0.0)

# Publish
npm publish
```

## Step 5: Verify Publication

1. Check your package on npm: `https://www.npmjs.com/package/react-native-voice-with-recording`
2. Test installation in a new project:
   ```bash
   npm install react-native-voice-with-recording
   ```

## Publishing Checklist

Before publishing, ensure you have:

- [ ] Updated `package.json` with correct author and repository information
- [ ] Built the TypeScript files (`npm run build`)
- [ ] Tested the build output
- [ ] Verified the package name is available
- [ ] Logged in to npm (`npm login`)
- [ ] Checked what files will be included (`npm pack --dry-run`)
- [ ] Updated version number if needed (`npm version patch/minor/major`)

## Common Issues and Solutions

### "Package name already exists"
- Choose a different name or add a scope: `@yourusername/react-native-voice-with-recording`

### "You must be logged in to publish packages"
- Run `npm login` and enter your credentials

### "Package name must be lowercase"
- Ensure your package name in `package.json` is all lowercase

### "Invalid package name"
- Package names can only contain lowercase letters, numbers, hyphens, and underscores

## Post-Publication

1. **Create a GitHub release** (if using GitHub)
2. **Update documentation** if needed
3. **Monitor for issues** and respond to user feedback
4. **Plan future updates** and maintain the package

## Unpublishing (if needed)

⚠️ **Warning**: Unpublishing can break other people's projects. Only do this if absolutely necessary.

```bash
# Unpublish a specific version
npm unpublish react-native-voice-with-recording@1.0.0

# Unpublish entire package (only within 72 hours of publishing)
npm unpublish react-native-voice-with-recording --force
```

## Best Practices

1. **Test thoroughly** before publishing
2. **Use semantic versioning** (semver)
3. **Write good documentation** in README.md
4. **Include examples** and usage instructions
5. **Respond to issues** and pull requests
6. **Keep dependencies updated**
7. **Test on both platforms** (Android and iOS)

## Next Steps After Publishing

1. Share your package on social media
2. Add it to React Native community lists
3. Write blog posts or tutorials
4. Monitor downloads and feedback
5. Plan future features and improvements 