
# Protecting Your Hugo Site with OAuth2 and Deploying to Fly.io

Example project to protect a Hugo site with OAuth2 and deploy to Fly.io.

## Introduction

This project serves as a template for learning how to use the [OAuth2 proxy](https://oauth2-proxy.github.io/oauth2-proxy/) to secure a static website. Specifically, it demonstrates deployment on [fly.io](http://fly.io) using [Hugo](https://gohugo.io). The primary goal is to provide internal project documentation for clients, enabling OAuth-based access to technical documents written in Markdown.

The motivation behind this project arose from the need to share technical documentation with clients while maintaining security. Although most of the writing is done in Markdown, the target audience often includes non-technical executives who find Markdown cumbersome. The solution aims to offer users a simple link to view technical documentation or project proposals.

Markdown and GitHub are preferred over Microsoft Office and Word due to their simplicity and ease of integration with tools like PlantUML, D2, and Mermaid for diagrams and other elements. This approach streamlines the process of creating and sharing detailed technical documents.

I struggled to get a working solution because the oAuth2 proxy documentation is very confusing and wrong in some places. I am documenting my process here, so I can find it again later. This is working with version 7.8 using some Alpha Configuration features.

I assume that you:

- Understand OAuth2
- Know what Hugo is or any other static site generator
- Understand Docker
- Have a basic understanding of Fly.io

The following diagram illustrates the architecture of the project:

![architecture](/docs/schematic.svg)

## Goals

- Protect a Hugo site with OAuth2 authentication.
- Deploy the site to Fly.io.
- Use GitHub as the OAuth2 provider.
  - Only Allow members of a specific GitHub organization to access the site.
- Ensure the site is accessible only to authenticated users.
- Provide a seamless user experience for accessing the site.
- Enable easy management of access permissions through GitHub.

## Configuration Steps

- Modify the `Fly.toml` file to your liking. The app name is set to `hugo-oauth2-flyio` but that will not work for you.
- Use the `fly launch` command to create a new application.
  - This will give you an URL that you can use for your GitHub OAuth2 configuration.
- You need to create a GitHub OAuth2 application at [https://github.com/settings/developers](https://github.com/settings/developers)
  - You will need to set the callback URL to the URL provided by Fly.io.
- GitHub gave you a Client ID and secret. These need to be setup as secrets in your Fly.io app.
  - Change this to your GitHub Client ID and secret.

```sh
fly secrets set GITHUB_CLIENT_ID=123
fly secrets set GITHUB_CLIENT_SECRET=abc
```

- The proxy requires that you generate a cookie secret. You can use the following command to generate a random value. See the oAuth2 proxy documentation for more information.

```sh
fly secrets set OAUTH2_PROXY_COOKIE_SECRET=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | tr -d -- '\n' | tr -- '+/' '-_'; echo)
```

- `proxy-alpha-config.yaml` file is the configuration file for the OAuth2 proxy.
  - This will need to be updated with your GitHub OAuth2 configuration.
  - Right now it is hard coded with my GitHub organization. You will need to change this to your GitHub organization or if you want to authenticate a github team member.

- The `Dockerfile` in this project builds the Hugo site, then use the Bitnami image to run the proxy. We copy the static files into the image and configure the proxy to serve the static files. The proxy is configured to use GitHub as the OAuth2 provider.

- Deploy to Fly.io

## User Experience

Because I have the entire site protected in the `proxy-alpha-config.yaml` file, if someone tries to access the site they will be redirected to a proxy login page.

![signon](/docs/login.png)

If they click on the GitHub button, they will be redirected to GitHub to authenticate. After they authenticate, they will be redirected back to the site.

![github](/docs/gh-oauth-flow.png)

In my case, the configuration is set up to only allow members of my GitHub organization to access the site. However, the user has to "Grant" access to the application. If they don't do this they will not be able to access the site and they do not get a good error message.

Once they are authenticated they can see the site. This screenshot is the static hugo site which just has links to the oAuth2 proxy routes.

![static site](/docs/static-site.png)


## References and Similar

- [oAuth2 Proxy Documentation](https://oauth2-proxy.github.io/oauth2-proxy/)
- Similar Example but on Render.com [https://render.com/blog/password-protect-with-oauth2-proxy](https://render.com/blog/password-protect-with-oauth2-proxy)
- Another example [https://github.com/hamelsmu/oauth-tutorial/tree/main/simple](https://github.com/hamelsmu/oauth-tutorial/tree/main/simple)
  - This example shows google auth and has a list of static email addresses.
  - It also does NOT use the alpha configuration and only command line flags on the proxy.
  - [YouTube Walkthrough](https://www.youtube.com/watch?v=EjEzZ4Hg-B4)