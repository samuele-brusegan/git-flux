// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_meta.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRepositoryMetaCollection on Isar {
  IsarCollection<RepositoryMeta> get repositoryMetas => this.collection();
}

const RepositoryMetaSchema = CollectionSchema(
  name: r'RepositoryMeta',
  id: 3435667939235634117,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.long,
    ),
    r'isFavorite': PropertySchema(
      id: 1,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'lastOpenedAt': PropertySchema(
      id: 2,
      name: r'lastOpenedAt',
      type: IsarType.dateTime,
    ),
    r'localPath': PropertySchema(
      id: 3,
      name: r'localPath',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 4, name: r'name', type: IsarType.string),
    r'remoteUrl': PropertySchema(
      id: 5,
      name: r'remoteUrl',
      type: IsarType.string,
    ),
  },

  estimateSize: _repositoryMetaEstimateSize,
  serialize: _repositoryMetaSerialize,
  deserialize: _repositoryMetaDeserialize,
  deserializeProp: _repositoryMetaDeserializeProp,
  idName: r'id',
  indexes: {
    r'localPath': IndexSchema(
      id: 183671076028779897,
      name: r'localPath',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'localPath',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _repositoryMetaGetId,
  getLinks: _repositoryMetaGetLinks,
  attach: _repositoryMetaAttach,
  version: '3.3.0',
);

int _repositoryMetaEstimateSize(
  RepositoryMeta object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.localPath.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.remoteUrl.length * 3;
  return bytesCount;
}

void _repositoryMetaSerialize(
  RepositoryMeta object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.accountId);
  writer.writeBool(offsets[1], object.isFavorite);
  writer.writeDateTime(offsets[2], object.lastOpenedAt);
  writer.writeString(offsets[3], object.localPath);
  writer.writeString(offsets[4], object.name);
  writer.writeString(offsets[5], object.remoteUrl);
}

RepositoryMeta _repositoryMetaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RepositoryMeta();
  object.accountId = reader.readLong(offsets[0]);
  object.id = id;
  object.isFavorite = reader.readBool(offsets[1]);
  object.lastOpenedAt = reader.readDateTime(offsets[2]);
  object.localPath = reader.readString(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.remoteUrl = reader.readString(offsets[5]);
  return object;
}

P _repositoryMetaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _repositoryMetaGetId(RepositoryMeta object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _repositoryMetaGetLinks(RepositoryMeta object) {
  return [];
}

void _repositoryMetaAttach(
  IsarCollection<dynamic> col,
  Id id,
  RepositoryMeta object,
) {
  object.id = id;
}

extension RepositoryMetaByIndex on IsarCollection<RepositoryMeta> {
  Future<RepositoryMeta?> getByLocalPath(String localPath) {
    return getByIndex(r'localPath', [localPath]);
  }

  RepositoryMeta? getByLocalPathSync(String localPath) {
    return getByIndexSync(r'localPath', [localPath]);
  }

  Future<bool> deleteByLocalPath(String localPath) {
    return deleteByIndex(r'localPath', [localPath]);
  }

  bool deleteByLocalPathSync(String localPath) {
    return deleteByIndexSync(r'localPath', [localPath]);
  }

  Future<List<RepositoryMeta?>> getAllByLocalPath(
    List<String> localPathValues,
  ) {
    final values = localPathValues.map((e) => [e]).toList();
    return getAllByIndex(r'localPath', values);
  }

  List<RepositoryMeta?> getAllByLocalPathSync(List<String> localPathValues) {
    final values = localPathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'localPath', values);
  }

  Future<int> deleteAllByLocalPath(List<String> localPathValues) {
    final values = localPathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'localPath', values);
  }

  int deleteAllByLocalPathSync(List<String> localPathValues) {
    final values = localPathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'localPath', values);
  }

  Future<Id> putByLocalPath(RepositoryMeta object) {
    return putByIndex(r'localPath', object);
  }

  Id putByLocalPathSync(RepositoryMeta object, {bool saveLinks = true}) {
    return putByIndexSync(r'localPath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLocalPath(List<RepositoryMeta> objects) {
    return putAllByIndex(r'localPath', objects);
  }

  List<Id> putAllByLocalPathSync(
    List<RepositoryMeta> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'localPath', objects, saveLinks: saveLinks);
  }
}

extension RepositoryMetaQueryWhereSort
    on QueryBuilder<RepositoryMeta, RepositoryMeta, QWhere> {
  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RepositoryMetaQueryWhere
    on QueryBuilder<RepositoryMeta, RepositoryMeta, QWhereClause> {
  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterWhereClause>
  localPathEqualTo(String localPath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'localPath', value: [localPath]),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterWhereClause>
  localPathNotEqualTo(String localPath) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localPath',
                lower: [],
                upper: [localPath],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localPath',
                lower: [localPath],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localPath',
                lower: [localPath],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localPath',
                lower: [],
                upper: [localPath],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension RepositoryMetaQueryFilter
    on QueryBuilder<RepositoryMeta, RepositoryMeta, QFilterCondition> {
  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  accountIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accountId', value: value),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  accountIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'accountId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  accountIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'accountId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  accountIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'accountId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  isFavoriteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isFavorite', value: value),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  lastOpenedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastOpenedAt', value: value),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  lastOpenedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastOpenedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  lastOpenedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastOpenedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  lastOpenedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastOpenedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  localPathEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  localPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  localPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  localPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  localPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  localPathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  localPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  localPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  localPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localPath', value: ''),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  localPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localPath', value: ''),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  remoteUrlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remoteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  remoteUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  remoteUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  remoteUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  remoteUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remoteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  remoteUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remoteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  remoteUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remoteUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  remoteUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remoteUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  remoteUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteUrl', value: ''),
      );
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterFilterCondition>
  remoteUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteUrl', value: ''),
      );
    });
  }
}

extension RepositoryMetaQueryObject
    on QueryBuilder<RepositoryMeta, RepositoryMeta, QFilterCondition> {}

extension RepositoryMetaQueryLinks
    on QueryBuilder<RepositoryMeta, RepositoryMeta, QFilterCondition> {}

extension RepositoryMetaQuerySortBy
    on QueryBuilder<RepositoryMeta, RepositoryMeta, QSortBy> {
  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> sortByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  sortByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  sortByLastOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  sortByLastOpenedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.desc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> sortByLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  sortByLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.desc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> sortByRemoteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  sortByRemoteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.desc);
    });
  }
}

extension RepositoryMetaQuerySortThenBy
    on QueryBuilder<RepositoryMeta, RepositoryMeta, QSortThenBy> {
  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> thenByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  thenByAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountId', Sort.desc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  thenByLastOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  thenByLastOpenedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedAt', Sort.desc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> thenByLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  thenByLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPath', Sort.desc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy> thenByRemoteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.asc);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QAfterSortBy>
  thenByRemoteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUrl', Sort.desc);
    });
  }
}

extension RepositoryMetaQueryWhereDistinct
    on QueryBuilder<RepositoryMeta, RepositoryMeta, QDistinct> {
  QueryBuilder<RepositoryMeta, RepositoryMeta, QDistinct>
  distinctByAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountId');
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QDistinct>
  distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QDistinct>
  distinctByLastOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastOpenedAt');
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QDistinct> distinctByLocalPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RepositoryMeta, RepositoryMeta, QDistinct> distinctByRemoteUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteUrl', caseSensitive: caseSensitive);
    });
  }
}

extension RepositoryMetaQueryProperty
    on QueryBuilder<RepositoryMeta, RepositoryMeta, QQueryProperty> {
  QueryBuilder<RepositoryMeta, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RepositoryMeta, int, QQueryOperations> accountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountId');
    });
  }

  QueryBuilder<RepositoryMeta, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<RepositoryMeta, DateTime, QQueryOperations>
  lastOpenedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastOpenedAt');
    });
  }

  QueryBuilder<RepositoryMeta, String, QQueryOperations> localPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localPath');
    });
  }

  QueryBuilder<RepositoryMeta, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<RepositoryMeta, String, QQueryOperations> remoteUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteUrl');
    });
  }
}
