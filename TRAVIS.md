Setting up Travis-CI Test Harness
=================================

These notes were cribbed from the work that Sean O'Meara did for the Yum cookbook.

# Ensure Travis integration is on in GitHub.
# Set up Gemfile, Rakefile like the ones here
# Set up .kitchen.cloud.yml
# Set up a .travis.yml without all the encrypted secrets but with the tasks, matrix, etc. This .travis.yml needs to have env vars like DIGITAL_OCEAN_SSH_KEY_PATH set up unencrypted in the env->global section.
# Install the Travis gem. Encrypt the secrets you will use. This is the trickiest part:
## Environment variables shorter than 90 characters are easy; just do ```travis encrypt FOO=bar --add```. For
DigitalOcean you need at least:

```
travis encrypt DIGITAL_OCEAN_CLIENT_ID=whatevs
travis encrypt DIGITAL_OCEAN_API_KEY=whatevs
travis encrypt DIGITAL_OCEAN_SSH_KEY_IDS=123456  # read kitchen-digitalocean's README to find out how to get this
```

## Environment variables longer than 90 characters require some incantation, e.g. for your SSH private key, do
something like:

```
base64 ~/.ssh/travisci_cook_digitalocean.pem | \
    awk '{
      j=0;
      for( i=1; i<length; i=i+90 ) {
        system("travis encrypt DO_KEY_CHUNK_" j "=" substr($0, i, 90) " --add");
j++;
      }
    }' 
```

# Push changes to a branch and hopefully Travis will pick it up and build your project and do integration testing
with Kitchen!
