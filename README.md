# Linkding on Fly.io

🔖 Run the self-hosted bookmark service [Linkding](https://github.com/sissbruecker/linkding) on [Fly.io](https://fly.io/). Automatically backup the bookmark database with [Litestream](https://litestream.io/).

## Pricing

Assuming one 256MB VM and a 3GB volume, this setup fits within Fly's free tier.

## Prerequisites

- A [fly.io](https://fly.io/) account
- [`flyctl` CLI installed](https://fly.io/docs/getting-started/installing-flyctl/)

Instructions below assume that you have cloned this repository to your local computer:

```sh
git clone https://github.com/trey/linkding-on-fly.git && cd linkding-on-fly
```

## Litestream - Create S3-compatible bucket and application key

Check litestream's ["Replica Guides"](https://litestream.io/guides/#replica-guides) section if you need to.

## Usage

```sh
flyctl auth login
```

Copy `.env.sample` to `.env` and adjust as needed.

```sh
fly secrets import < .env
flyctl launch
```

## Verify the Installation

- You should be able to log into your linkding instance.
- There should be an initial replica of your database in your S3-compatible bucket.
- Your user data should survive a restart of the VM.

## Create daily snapshots and save them to another S3-compatible bucket

TODO
