alias Acl.Accessibility.Always, as: AlwaysAccessible
alias Acl.Accessibility.ByQuery, as: AccessByQuery
alias Acl.GraphSpec.Constraint.Resource.AllPredicates, as: AllPredicates
alias Acl.GraphSpec.Constraint.Resource.NoPredicates, as: NoPredicates
alias Acl.GraphSpec.Constraint.ResourceFormat, as: ResourceFormatConstraint
alias Acl.GraphSpec.Constraint.Resource, as: ResourceConstraint
alias Acl.GraphSpec, as: GraphSpec
alias Acl.GroupSpec, as: GroupSpec
alias Acl.GroupSpec.GraphCleanup, as: GraphCleanup

defmodule Acl.UserGroups.Config do
  def user_groups do
    [
      %GroupSpec{
        name: "public",
        useage: [:read],
        access: %AlwaysAccessible{},
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/authors",
            constraint: %ResourceConstraint{
              resource_types: [
                "http://xmlns.com/foaf/0.1/Person",
              ],
              predicates: %NoPredicates{
                except: [ "http://xmlns.com/foaf/0.1/name" ]
              }
            }
          },
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/public",
            constraint: %ResourceConstraint{
              resource_types: [
                "http://schema.org/Book",
                "http://schema.org/Library",
                "http://schema.org/ItemAvailability"
              ]
            }
          }
        ]
      },

      %GroupSpec{
        name: "private",
        useage: [],
        access: %AccessByQuery{
          vars: [],
          query: "SELECT ?foo FROM <http://i-do-not-exist.com/nope> WHERE { ?foo ?p ?o. }"
        },
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/private",
            constraint: %ResourceConstraint{
              resource_types: [
                "http://xmlns.com/foaf/0.1/OnlineAccount",
              ],
              predicates: %NoPredicates{
                except: [ "http://xmlns.com/foaf/0.1/accountName" ]
              },
              inverse_predicates: %NoPredicates{
                except: [ "http://xmlns.com/foaf/0.1/account",
                          "http://mu.semte.ch/vocabularies/session/account" ]
              }
            }
          },
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/private",
            constraint: %ResourceConstraint{
              resource_types: [
                "http://xmlns.com/foaf/0.1/Person"
              ],
              inverse_predicates: %NoPredicates{
                except: [ "http://xmlns.com/foaf/0.1/member" ]
              }
            }
          }

        ]
      },

      %GroupSpec{
        name: "management",
        useage: [:read, :write, :read_for_write],
        access: %AccessByQuery{
          vars: [],
          query: "SELECT * WHERE {
          <SESSION_ID> <http://mu.semte.ch/vocabularies/session/account> ?account.
          ?person <http://xmlns.com/foaf/0.1/account> ?account.
          <http://books.com/groups/curators> <http://xmlns.com/foaf/0.1/member> ?person.
          }"
        },
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/management",
            constraint: %ResourceConstraint{
              resource_types: [
                "http://xmlns.com/foaf/0.1/Project"
              ],
              predicates: %AllPredicates{},
              inverse_predicates: %AllPredicates{}
            }
          }
        ]
      },

      %GroupSpec{
        name: "library-member",
        useage: [:read, :read_for_write],
        access: %AccessByQuery{
          vars: ["libraryName"],
          query: "SELECT ?libraryName WHERE {
          <SESSION_ID> <http://mu.semte.ch/vocabularies/session/account> ?account.
          ?person <http://xmlns.com/foaf/0.1/account> ?account.
          ?person <http://mu.semte.ch/vocabularies/ext/memberOfLibrary> ?library.
          ?library <http://schema.org/name> ?libraryName.
          }"
        },
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/library/",
            constraint: %ResourceConstraint{
              resource_types: [
                "http://schema.org/Offer"
              ]
            }
          }
        ]
      },

      %GroupSpec{
        name: "library-owner",
        useage: [:read, :write, :read_for_write],
        access: %AccessByQuery{
          vars: ["libraryName"],
          query: "SELECT ?libraryName WHERE {
          <SESSION_ID> <http://mu.semte.ch/vocabularies/session/account> ?account.
          ?person <http://xmlns.com/foaf/0.1/account> ?account.
          ?person <http://mu.semte.ch/vocabularies/ext/ownerOfLibrary> ?library.
          ?library <http://schema.org/name> ?libraryName.
          }"
        },
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/library/",
            constraint: %ResourceConstraint{
              resource_types: [
                "http://schema.org/Offer"
              ]
            }
          }
        ]
      },

      %GraphCleanup{
        originating_graph: "http://mu.semte.ch/application",
        useage: [:write],
        name: "clean"
      }
    ]
  end
end
