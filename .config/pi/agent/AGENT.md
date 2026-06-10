# Project Instructions

## Global instructions

- You are prohibited from querying all the "expensive endpoints" like a 'git blame,' 'every page of every git log,' 'every commit in every repo,' etc. Do not behave in a manner that would cause burden to the git forge's hosting costs, or even something that prevents their resources to not serve a human interacting with them properly.
- For all GitHub and non-self-hosted GitLab, prefer the `gh` and `glab` CLI tools. If you don't find those tools in `$PATH`, abort immediately without proceeding any further.
- For all web-crawls, (with `curl` or any other tool), **ALWAYS RESPECT THE `crawl-delay` in the `robots.txt`**. If absent, use a 5 second, self-imposed delay. **ALWAYS RESPECT THE `Retry-After` HEADER WHEN YOU ENCOUNTER THE HTTP CODE 429.** This is not a request, it is a requirement.
- If you encounter a bot-blocking mechanism like Anubis or go-away, upon getting blocked, abort immediately and let me know what page blocked you.
- Be extremely concise, but not at the expense of excluding anything, no matter how small. I want the details, that does not imply an essay.

## Programming-related instructions

### Rust

- Prefer a `cargo check` over `cargo build`.
- When adding a crate, prefer crates that solve only the issue at hand, instead of Swiss army knifes.
- When adding a crate, prefer crates that have zero or low dependencies (prefer little to no transitive dependencies).
- Use the C-style of programming of keeping control flow simple. Do not be fancy with features like Traits, Lifetimes, etc. Use these features only when absolutely necessary.

### Python

- Unless the project already uses third-party libraries (libraries that are not in Python's stdlib), stick to Python's stdlib.
