// 中文标签映射与枚举，集中管理便于复用
export const GENRE_LABELS = {
  werewolf: '狼人',
  ceo: '霸总',
  reborn: '重生',
  vampire: '吸血鬼',
  romantasy: '浪漫奇幻',
  modern: '现代言情',
};

export const STATUS_LABELS = {
  ongoing: '连载中',
  complete: '已完结',
};

export const ORDER_STATUS = {
  paid: { label: '已支付', tone: 'success' },
  pending: { label: '待支付', tone: 'warn' },
  refunded: { label: '已退款', tone: 'danger' },
};

export const USER_STATUS = {
  active: { label: '正常', tone: 'success' },
  banned: { label: '已封禁', tone: 'danger' },
};
