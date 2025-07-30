# Terraform Volterra

## New Version
If changes are made, use the following to deploy the new version. The only thing to remember is that if it is a new module and not a module update, the module folder should be created via the automation repository first.

1. **Create a new branch**  
   Start by creating a new branch using one of the following prefixes:  
   - `release/`
   - `feature/`

2. **Apply your changes**  
   Implement the required changes and **update the version number** in **all relevant `README.md` files**.

3. **Commit and push**  
   Once all changes are complete, commit your work and push the branch to GitLab.

4. **Test the module**  
   Use the **commit SHA** (available under **Code → Commits** in the GitLab interface) to test your module.

5. **Merge and tag**  
   After successful testing:
   - Open a **merge request** and merge the branch into `main`.
   - Create a new **Git tag** from the `main` branch using the GitLab GUI.