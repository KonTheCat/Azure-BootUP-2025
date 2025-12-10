# GitHub Codespaces Collaboration Guide

## How to Access Someone Else's Codespace

GitHub Codespaces allows developers to work in cloud-based development environments. While you cannot directly access someone else's **running** codespace, there are several ways to collaborate effectively:

## Option 1: Share a Codespace via Live Share (Recommended for Real-Time Collaboration)

**Live Share** is the best way to collaborate in real-time within a codespace.

### Steps to Share Your Codespace:
1. Open your codespace
2. Install the **Live Share extension** (if not already installed)
   - Click the Extensions icon in VS Code
   - Search for "Live Share"
   - Click Install
3. Click the **Live Share** button in the status bar (bottom of VS Code)
4. Click **Share** to generate a collaboration link
5. Share the link with your collaborator
6. Your collaborator can click the link to join your codespace session

### Steps to Join Someone's Codespace:
1. Receive the Live Share link from your collaborator
2. Click the link (opens in your browser)
3. You'll be prompted to:
   - Continue in VS Code Desktop, or
   - Continue in VS Code for Web
4. Once connected, you can:
   - See their code in real-time
   - Edit files together
   - Share a terminal
   - Debug together

**Note**: Live Share sessions are temporary and end when the host disconnects.

## Option 2: Fork the Repository

If you want to work on someone's code independently:

### Steps:
1. Go to the repository on GitHub
2. Click the **Fork** button (top right)
3. This creates a copy of the repository under your account
4. Open your forked repository in a codespace:
   - Click the green **Code** button
   - Select **Codespaces** tab
   - Click **Create codespace on main** (or your desired branch)

**Benefits**:
- You have full control over your own codespace
- Changes don't affect the original repository
- You can submit pull requests to contribute back

## Option 3: Clone the Repository

For working with shared code locally or in your own codespace:

### Steps:
1. Navigate to the repository on GitHub
2. Click the green **Code** button
3. Copy the repository URL
4. In your codespace or terminal:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

## Option 4: Collaborate via Pull Requests

The standard GitHub workflow for collaboration:

### Steps:
1. Fork or clone the repository
2. Create a new branch:
   ```bash
   git checkout -b my-feature-branch
   ```
3. Make your changes
4. Commit and push:
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin my-feature-branch
   ```
5. Go to GitHub and create a **Pull Request**
6. The repository owner can review and merge your changes

## Security and Permissions

**Important Notes**:
- **Codespaces are private** by default - only the owner can access them
- You cannot "take over" or directly access someone else's running codespace
- **Live Share** is the only way to grant temporary, collaborative access
- Repository permissions control who can:
  - View code
  - Create codespaces
  - Push changes
  - Merge pull requests

## Best Practices for Course Collaboration

For this Azure BootUP 2025 course:

1. **For Lab Work Together**:
   - Use **Live Share** to help each other with labs
   - Share your codespace session link in Slack

2. **For Sharing Solutions**:
   - Fork the main repository
   - Work in your own codespace
   - Create a pull request if you want to contribute back

3. **For Learning from Others**:
   - Clone or fork their repository
   - Create your own codespace from it
   - Experiment and learn

4. **For Code Review**:
   - Review pull requests on GitHub
   - Leave comments and suggestions
   - Use GitHub's review tools

## Common Questions

**Q: Can I access someone's codespace without permission?**  
A: No. Codespaces are private and require explicit sharing via Live Share.

**Q: How long does a Live Share session last?**  
A: As long as the host keeps it active. It ends when the host disconnects.

**Q: Can multiple people edit the same file at once?**  
A: Yes, with Live Share, multiple collaborators can edit simultaneously (like Google Docs).

**Q: Will changes in a Live Share session affect the original code?**  
A: Only if the host saves and commits them. Guests' changes appear in the host's environment.

**Q: Can I create a codespace from any repository?**  
A: Only if you have access to the repository (public repos or repos you have permission to access).

## Additional Resources

- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [VS Code Live Share Documentation](https://learn.microsoft.com/en-us/visualstudio/liveshare/)
- [GitHub Collaboration Guide](https://docs.github.com/en/get-started/quickstart/github-flow)
- [Forking a Repository](https://docs.github.com/en/get-started/quickstart/fork-a-repo)

---

**Need Help?** Ask questions in the course Slack channel or reach out to the instructor!
