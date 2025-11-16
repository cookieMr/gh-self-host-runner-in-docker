# GitHub Self Hosted Runner (as Docker)

Attach a self hosted runner to you repo. E.g. to run workflows in private
repo without time limits (it's [2000 min](https://docs.github.com/en/billing/concepts/product-billing/github-actions#free-use-of-github-actions) per month in a *GitHub Free* plan).

## Creating the `.env` file
Use `.env_example` as a template to create the `.env` file that will
provide secrets and configuration variables to the `docker-compose`.
 * `GITHUB_OWNER` - your user name
 * `GITHUB_REPOSITORY` - repo where the self hosted runner will be available `(*)`
 * `GITHUB_PAT` - a *personal access token* that you'll get from the GitHub:
    * open your profile `Settings`
    * on left menu, at the bottom choose `Developer settings`
    * expand the `Personal Access tokens` and choose `Token (classic)`
    * `Generate new token` -> `Generate new token (classic)`
    * give it a note, an expiration, and then choose these scopes:
        * `repo` - Full control of private repositories
        * `admin:repo_hook` - Full control of repository hooks
    * `Save`
    * Copy the token value and store is securly (e.g. in
      [Keepass XC](https://github.com/keepassxreboot/keepassxc))
    * paste it into the `.env` file as the `GITHUB_PAT` value.

> Do not commit `.env` file! Keep it in `.gitignore`! Just do it!

> `(*)` Without creating an organization this self hosted runner can
> be registered only in a single repo via `GITHUB_REPOSITORY`.

## Build `Dockerfile`
```bash
docker build --no-cache --tag gh-runner .
```
## Run container
```bash
docker-compose up --build --detach
```
And a clean up command:
```bash
docker-compose down --remove-orphans --volumes
```
I use [lazydocker](https://github.com/jesseduffield/lazydocker) to manage running containers and preview logs.
