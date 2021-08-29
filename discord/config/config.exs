# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :discord_foundation, Mongo.Repo,
       adapter: Mongo.Ecto,

#       hostname: " discordgroup-shard-00-01.n0ujo.mongodb.net",
#       port: 27017
#       hostname: "discordgroup.n0ujo.mongodb.net",
       mongo_url: "mongodb+srv://mongo:test@discordgroup.n0ujo.mongodb.net/myFirstDatabasse?retryWrites=true&w=majority"

#  hostname: "mongodb+srv://mongo:test@discordgroup.n0ujo.mongodb.net/myFirstDatabasse?retryWrites=true&w=majority"
#mongodb+srv://mongo:test@discordgroup.n0ujo.mongodb.net/myFirstDatabase?retryWrites=true&w=majority

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#

