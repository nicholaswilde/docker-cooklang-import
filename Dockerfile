# https://github.com/LukeMathWalker/cargo-chef

FROM rust:latest AS planner

WORKDIR /app
RUN git clone https://github.com/cooklang/cooklang-import.git
RUN cargo chef prepare --recipe-path recipe.json

FROM rust:latest AS builder

WORKDIR /app
COPY --from=planner /app/recipe.json recipe.json
COPY --from=planner /app/src/ ./src/

RUN cargo chef cook --recipe-path recipe.json
# Change directory to the cloned repository
#  WORKDIR /app/cooklang-import

# Build the project
# RUN \
#   cargo update && \
#   cargo build --release

# Create a new, smaller image for runtime
FROM rust:slim

# Copy the built binary from the builder stage
COPY --from=builder /app/target/release/cooklang-import /usr/local/bin/cooklang-import

# Set the entrypoint to the binary
ENTRYPOINT ["/usr/local/bin/cooklang-import"]
