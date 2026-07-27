# Apollo Patterns Reference

Advanced Apollo Client patterns for cache management, optimistic updates, subscriptions, and performance optimization.

## Core Capabilities

- Apollo Client setup with proper TypeScript integration and code generation
- Efficient queries, mutations, and subscriptions with proper error handling
- Cache management with normalized cache and optimistic updates
- Real-time features with GraphQL subscriptions and connection management
- Performance optimization through query batching and cache policies

## Cache Management

### Normalized Cache

Apollo's `InMemoryCache` automatically normalizes data by `__typename` and `id`. Understanding this is key to advanced cache operations.

```typescript
const cache = new InMemoryCache({
  typePolicies: {
    Query: {
      fields: {
        todos: {
          // Merge function for paginated data
          keyArgs: ['filter'],
          merge(existing = [], incoming, { args }) {
            if (args?.offset === 0) return incoming;
            return [...existing, ...incoming];
          },
        },
      },
    },
    User: {
      // Custom key fields (default is id)
      keyFields: ['userId'],
    },
  },
});
```

### Direct Cache Reads and Writes

```typescript
// Read from cache
const user = client.readFragment<UserFragment>({
  id: `User:${userId}`,
  fragment: USER_FRAGMENT,
});

// Write to cache
client.writeFragment({
  id: `User:${userId}`,
  fragment: USER_FRAGMENT,
  data: { ...user, name: 'Updated Name' },
});

// Read a full query from cache
const data = client.readQuery<GetTodosQuery>({
  query: GET_TODOS,
  variables: { filter: 'active' },
});
```

### cache.modify for Surgical Updates

```typescript
cache.modify({
  id: cache.identify(todo),
  fields: {
    completed: (value) => !value,
  },
});

// Modify root query fields
cache.modify({
  fields: {
    todos(existingRefs, { readField }) {
      return existingRefs.filter(
        (ref: Reference) => readField('id', ref) !== deletedId
      );
    },
  },
});
```

### Evicting Cache Entries

```typescript
// Remove a specific entity
cache.evict({ id: `User:${userId}` });

// Remove a specific field
cache.evict({ id: `User:${userId}`, fieldName: 'posts' });

// Garbage collect unreachable entries
cache.gc();
```

## Optimistic Updates

Provide instant UI feedback while mutations are in flight.

### Basic Optimistic Response

```typescript
const [toggleTodo] = useToggleTodoMutation({
  optimisticResponse: {
    __typename: 'Mutation',
    toggleTodo: {
      __typename: 'Todo',
      id: todoId,
      completed: !currentCompleted,
    },
  },
});
```

### Optimistic Update with Cache Modification

```typescript
const [addItem] = useAddItemMutation({
  optimisticResponse: {
    __typename: 'Mutation',
    addItem: {
      __typename: 'Item',
      id: `temp-${Date.now()}`,
      name: newItemName,
      createdAt: new Date().toISOString(),
    },
  },
  update(cache, { data }) {
    if (!data) return;

    cache.modify({
      fields: {
        items(existingItems = []) {
          const newItemRef = cache.writeFragment({
            data: data.addItem,
            fragment: ITEM_FRAGMENT,
          });
          return [...existingItems, newItemRef];
        },
      },
    });
  },
});
```

### Handling Optimistic Rollback

When the server returns an error, Apollo automatically reverts optimistic changes. Handle this gracefully:

```typescript
const [deleteItem] = useDeleteItemMutation({
  optimisticResponse: {
    __typename: 'Mutation',
    deleteItem: { __typename: 'Item', id: itemId },
  },
  update(cache, { data }) {
    cache.evict({ id: `Item:${data?.deleteItem.id}` });
    cache.gc();
  },
  onError(error) {
    // Optimistic update is automatically rolled back
    // Show user-facing error
    toast.error(`Failed to delete: ${error.message}`);
  },
});
```

## Subscription Patterns

### Basic Subscription Setup

```typescript
import { GraphQLWsLink } from '@apollo/client/link/subscriptions';
import { createClient } from 'graphql-ws';
import { split, HttpLink } from '@apollo/client';
import { getMainDefinition } from '@apollo/client/utilities';

const wsLink = new GraphQLWsLink(
  createClient({
    url: 'ws://localhost:4000/graphql',
    connectionParams: {
      authToken: getAuthToken(),
    },
  })
);

const httpLink = new HttpLink({ uri: '/graphql' });

const splitLink = split(
  ({ query }) => {
    const definition = getMainDefinition(query);
    return (
      definition.kind === 'OperationDefinition' &&
      definition.operation === 'subscription'
    );
  },
  wsLink,
  httpLink
);
```

### Using Subscriptions in Components

```typescript
const MESSAGES_SUBSCRIPTION = gql`
  subscription OnNewMessage($channelId: ID!) {
    messageAdded(channelId: $channelId) {
      id
      text
      sender {
        id
        name
      }
      createdAt
    }
  }
`;

function ChatRoom({ channelId }: { channelId: string }) {
  const { data, loading } = useMessagesQuery({
    variables: { channelId },
  });

  useSubscription(MESSAGES_SUBSCRIPTION, {
    variables: { channelId },
    onData({ client, data: subData }) {
      // Update cache with new message
      client.cache.modify({
        fields: {
          messages(existingMessages = []) {
            const newMessageRef = client.cache.writeFragment({
              data: subData.data?.messageAdded,
              fragment: MESSAGE_FRAGMENT,
            });
            return [...existingMessages, newMessageRef];
          },
        },
      });
    },
  });

  if (loading) return <Spinner />;
  return <MessageList messages={data?.messages ?? []} />;
}
```

### subscribeToMore Pattern

```typescript
function Comments({ postId }: { postId: string }) {
  const { data, subscribeToMore } = useCommentsQuery({
    variables: { postId },
  });

  useEffect(() => {
    const unsubscribe = subscribeToMore<OnNewCommentSubscription>({
      document: ON_NEW_COMMENT,
      variables: { postId },
      updateQuery(prev, { subscriptionData }) {
        if (!subscriptionData.data) return prev;
        const newComment = subscriptionData.data.commentAdded;
        return {
          ...prev,
          comments: [...prev.comments, newComment],
        };
      },
    });

    return () => unsubscribe();
  }, [postId, subscribeToMore]);

  return <CommentList comments={data?.comments ?? []} />;
}
```

## Performance Optimization

### Query Batching

```typescript
import { BatchHttpLink } from '@apollo/client/link/batch-http';

const batchLink = new BatchHttpLink({
  uri: '/graphql',
  batchMax: 10,        // Max operations per batch
  batchInterval: 20,   // Batch window in ms
});
```

### Query Deduplication

Apollo deduplicates identical in-flight queries by default. Ensure this is enabled:

```typescript
const client = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'cache-and-network',
    },
  },
  queryDeduplication: true, // default is true
});
```

### Fetch Policy Selection

| Policy | Network Request | Cache Read | Best For |
|--------|----------------|------------|----------|
| `cache-first` | Only if cache miss | Yes | Static/rarely-changing data |
| `cache-and-network` | Always | Yes (stale) | Frequently-changing data with fast UI |
| `network-only` | Always | No | Data that must always be fresh |
| `cache-only` | Never | Yes | Offline or pre-loaded data |
| `no-cache` | Always | No | One-off queries, mutations |

### Prefetching

```typescript
function ProductList({ products }: { products: Product[] }) {
  const client = useApolloClient();

  const prefetchProduct = (productId: string) => {
    client.query({
      query: GET_PRODUCT_DETAIL,
      variables: { id: productId },
    });
  };

  return (
    <ul>
      {products.map(product => (
        <li key={product.id} onMouseEnter={() => prefetchProduct(product.id)}>
          <Link to={`/products/${product.id}`}>{product.name}</Link>
        </li>
      ))}
    </ul>
  );
}
```

## Error Handling Patterns

### Per-Query Error Handling

```typescript
const { data, error, loading } = useGetUserQuery({
  variables: { id: userId },
  errorPolicy: 'all', // Return partial data with errors
  onError(error) {
    if (error.networkError) {
      toast.error('Network error. Please check your connection.');
    }
  },
});
```

### Global Error Link

```typescript
const errorLink = onError(({ graphQLErrors, networkError, operation, forward }) => {
  if (graphQLErrors) {
    for (const err of graphQLErrors) {
      if (err.extensions?.code === 'UNAUTHENTICATED') {
        // Refresh token and retry
        return fromPromise(refreshToken()).flatMap(() => forward(operation));
      }
    }
  }
  if (networkError) {
    console.error(`[Network error]: ${networkError}`);
  }
});
```

## Anti-Patterns to Prevent

- Ignoring the normalized cache and always refetching
- Writing complex cache update logic when `refetchQueries` would suffice
- Not providing `__typename` in optimistic responses
- Creating subscriptions without cleanup (memory leaks)
- Using `no-cache` as a default fetch policy
- Not handling subscription reconnection on network failures
- Over-batching queries that should load independently

## What This Reference Does NOT Cover

- Backend GraphQL schema design
- GraphQL Code Generator setup (see `graphql-integration.md`)
- Basic Apollo query/mutation patterns (see `graphql-integration.md`)

## Goal

Help developers build efficient, real-time GraphQL applications with proper cache management, optimistic UI patterns, and subscription-based features using Apollo Client.
